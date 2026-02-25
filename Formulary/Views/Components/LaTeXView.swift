import SwiftUI
import WebKit

/// A reusable LaTeX rendering view using KaTeX via WKWebView.
/// Dynamically sizes to its rendered content via JS → Swift callback.
struct LaTeXView: UIViewRepresentable {
    let latex: String
    var fontSize: CGFloat = 18
    var displayMode: Bool = true
    /// The ACTUAL container width in points injected from SwiftUI's GeometryReader.
    /// This eliminates reliance on window.innerWidth (which is 0 during JS execution).
    var containerWidth: CGFloat = 320
    /// Called once the WebView has rendered and measured its content height (in points).
    var onHeightMeasured: ((CGFloat) -> Void)? = nil
    @Environment(\.colorScheme) private var colorScheme

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        config.userContentController.add(context.coordinator, name: "heightHandler")

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.navigationDelegate = context.coordinator
        webView.isUserInteractionEnabled = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
        // Start invisible — revealed after first height measurement to avoid jump
        webView.alpha = 0

        context.coordinator.onHeightMeasured = onHeightMeasured
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.onHeightMeasured = onHeightMeasured

        // Build a content key — only reload when content actually changes.
        // This breaks the SwiftUI re-render → reload → height-change → re-render loop.
        let isDark = colorScheme == .dark
        // Round containerWidth to nearest 2pt so minor layout passes don't reload
        let roundedWidth = round(containerWidth / 2) * 2
        let key = "\(latex)|\(fontSize)|\(isDark)|\(roundedWidth)"
        guard key != context.coordinator.lastLoadedKey else { return }
        context.coordinator.lastLoadedKey = key

        webView.alpha = 0   // hide until new render is measured
        let html = generateHTML()
        webView.loadHTMLString(html, baseURL: nil)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private func generateHTML() -> String {
        let textColor = colorScheme == .dark ? "#FFFFFF" : "#1A1A2E"
        let escapedLatex = latex
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\n", with: "\\n")

        // Usable pixel width = points × device pixel ratio.
        // Subtract 16pt horizontal padding (8pt each side) then convert to CSS px.
        // We inject this from Swift so JS gets a reliable number even before layout.
        let usableCSSpx = max(1, containerWidth - 16)

        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">
            <script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                html { background: transparent; }
                body {
                    background: transparent;
                    overflow-x: hidden;
                    color: \(textColor);
                    display: flex;
                    justify-content: center;
                    align-items: flex-start;
                    padding: 14px 8px;
                    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                    width: \(usableCSSpx + 16)px;
                }
                #math {
                    font-size: \(fontSize)px;
                    text-align: center;
                    transform-origin: top center;
                    display: inline-block;
                    max-width: \(usableCSSpx)px;
                }
                .katex { color: \(textColor) !important; }
                .katex-display { overflow-x: visible !important; overflow-y: visible !important; }
                .katex .mord, .katex .mbin, .katex .mrel,
                .katex .mopen, .katex .mclose, .katex .mpunct,
                .katex .mop, .katex .minner {
                    color: \(textColor) !important;
                }
            </style>
        </head>
        <body>
            <div id="math"></div>
            <script>
                var TARGET_FS = \(fontSize);
                var MIN_FS = 9;
                // AVAIL: injected from Swift — the actual usable CSS width in points.
                // This is reliable unlike window.innerWidth which is 0 during JS init.
                var AVAIL = \(usableCSSpx);
                var latexStr = '\(escapedLatex)';
                var mathEl = document.getElementById('math');

                function doRender(fs) {
                    mathEl.style.fontSize = fs + 'px';
                    // Reset any transform before measuring
                    mathEl.style.transform = '';
                    mathEl.style.marginBottom = '';
                    try {
                        katex.render(latexStr, mathEl, {
                            displayMode: \(displayMode ? "true" : "false"),
                            throwOnError: false,
                            strict: false,
                            trust: true,
                            macros: { '\\\\vec': '\\\\mathbf' }
                        });
                    } catch(e) {
                        mathEl.textContent = latexStr;
                    }
                }

                // Stage 1: initial render at full size
                doRender(TARGET_FS);

                // Stage 2: if formular wider than container, reduce font proportionally
                var mw = mathEl.scrollWidth;
                if (mw > AVAIL) {
                    var ratio = AVAIL / mw;
                    var newFS = Math.max(MIN_FS, Math.floor(TARGET_FS * ratio * 0.92));
                    doRender(newFS);

                    // Stage 3: still overflowing → CSS scale transform as final catch-all
                    mw = mathEl.scrollWidth;
                    if (mw > AVAIL) {
                        var scaleF = Math.max(0.30, AVAIL / mw);
                        mathEl.style.transform = 'scale(' + scaleF + ')';
                        mathEl.style.transformOrigin = 'top center';
                        var renderedH = mathEl.getBoundingClientRect().height;
                        mathEl.style.marginBottom = '-' + Math.round(renderedH * (1 - scaleF)) + 'px';
                    }
                }

                // Report height back to Swift
                var totalH = document.body.getBoundingClientRect().height;
                window.webkit.messageHandlers.heightHandler.postMessage(Math.max(60, totalH));
            </script>
        </body>
        </html>
        """
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var onHeightMeasured: ((CGFloat) -> Void)?
        /// Tracks the last content loaded so `updateUIView` can skip unnecessary reloads
        var lastLoadedKey: String = ""

        /// Receive height posted from inline JS — fires synchronously after render
        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            guard message.name == "heightHandler",
                  let h = message.body as? Double, h > 0 else { return }
            let height = CGFloat(h)
            DispatchQueue.main.async {
                self.onHeightMeasured?(height)
                // Fade the WebView in now that it has correct size — eliminates the jump/trembling
                if let wv = message.webView, wv.alpha < 1 {
                    UIView.animate(withDuration: 0.15) { wv.alpha = 1 }
                }
            }
        }

        // NOTE: didFinish navigation fallback intentionally removed.
        // The inline <script> posts height before the page finishes loading,
        // so the fallback was causing a second layout pass (the source of trembling).
    }
}

/// A compact inline LaTeX view for use in cards and lists
struct CompactLaTeXView: View {
    let latex: String
    var fontSize: CGFloat = 16
    @State private var renderedHeight: CGFloat = 70

    var body: some View {
        GeometryReader { geo in
            let responsiveFS = min(fontSize, max(11, floor(fontSize * geo.size.width / 390)))
            LaTeXView(latex: latex, fontSize: responsiveFS, displayMode: false, containerWidth: geo.size.width) { h in
                // Suppress animation on height change so the card doesn't visually "jump"
                var tx = Transaction()
                tx.disablesAnimations = true
                withTransaction(tx) { renderedHeight = max(60, h) }
            }
            .frame(width: geo.size.width, height: renderedHeight)
        }
        .frame(height: renderedHeight)
    }
}

/// A larger LaTeX view for detail screens — dynamically sizes to content.
/// Uses GeometryReader to derive a screen-width-aware target font size,
/// then lets the in-HTML JS further scale down if overflow is detected.
struct DetailLaTeXView: View {
    let latex: String
    var fontSize: CGFloat = 22
    @State private var renderedHeight: CGFloat = 120

    var body: some View {
        GeometryReader { geo in
            // Scale the target font size proportionally to screen width.
            // Base reference: 390pt (iPhone 15/16 logical width).
            // Clamp between 14 and the caller-supplied max.
            let responsiveFS = min(fontSize, max(14, floor(fontSize * geo.size.width / 390)))
            LaTeXView(latex: latex, fontSize: responsiveFS, displayMode: true, containerWidth: geo.size.width) { h in
                // Use no-animation transaction so the enclosing card doesn't flicker
                var tx = Transaction()
                tx.disablesAnimations = true
                withTransaction(tx) { renderedHeight = max(80, h) }
            }
            .frame(width: geo.size.width, height: renderedHeight)
        }
        .frame(height: renderedHeight)
    }
}

#Preview {
    VStack(spacing: 20) {
        CompactLaTeXView(latex: "x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}")
        DetailLaTeXView(latex: "E = mc^2")
        DetailLaTeXView(latex: "\\int_a^b f(x)\\,dx = F(b) - F(a)")
    }
    .padding()
}
