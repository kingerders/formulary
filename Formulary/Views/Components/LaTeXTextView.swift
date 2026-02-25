import SwiftUI

/// A lightweight text-based LaTeX display for use in cards and lists.
/// This avoids the heavy WKWebView overhead by rendering a simplified plain-text version.
struct LaTeXTextView: View {
    let latex: String
    var fontSize: CGFloat = 14
    var color: Color = .secondary
    var maxLines: Int? = 1
    var alignment: TextAlignment = .leading

    var body: some View {
        Text(simplifiedLatex)
            .font(.system(size: fontSize, weight: .regular, design: .serif))
            .foregroundStyle(color)
            .lineLimit(maxLines)
            .multilineTextAlignment(alignment)
            .minimumScaleFactor(0.6)
    }

    /// Convert LaTeX string to a human-readable simplified form
    private var simplifiedLatex: String {
        var s = latex

        // Pre-process: handle \frac{num}{den} → (num)/(den) before other replacements
        s = processFractions(s)
        // Pre-process: handle \sqrt{expr} → √(expr)
        s = processSqrt(s)

        // Replace common LaTeX commands with unicode equivalents
        let replacements: [(String, String)] = [
            ("\\\\", "⧹"),
            ("\\pm", "±"),
            ("\\mp", "∓"),
            ("\\times", "×"),
            ("\\cdot", "·"),
            ("\\div", "÷"),
            ("\\leq", "≤"),
            ("\\geq", "≥"),
            ("\\neq", "≠"),
            ("\\approx", "≈"),
            ("\\infty", "∞"),
            ("\\sum", "Σ"),
            ("\\prod", "Π"),
            ("\\int", "∫"),
            ("\\partial", "∂"),
            ("\\nabla", "∇"),
            ("\\Delta", "Δ"),
            ("\\delta", "δ"),
            ("\\alpha", "α"),
            ("\\beta", "β"),
            ("\\gamma", "γ"),
            ("\\theta", "θ"),
            ("\\lambda", "λ"),
            ("\\mu", "μ"),
            ("\\sigma", "σ"),
            ("\\Sigma", "Σ"),
            ("\\pi", "π"),
            ("\\Pi", "Π"),
            ("\\omega", "ω"),
            ("\\Omega", "Ω"),
            ("\\phi", "φ"),
            ("\\Phi", "Φ"),
            ("\\psi", "ψ"),
            ("\\Psi", "Ψ"),
            ("\\epsilon", "ε"),
            ("\\varepsilon", "ε"),
            ("\\rho", "ρ"),
            ("\\tau", "τ"),
            ("\\eta", "η"),
            ("\\zeta", "ζ"),
            ("\\kappa", "κ"),
            ("\\nu", "ν"),
            ("\\chi", "χ"),
            ("\\xi", "ξ"),
            ("\\left", ""),
            ("\\right", ""),
            ("\\text", ""),
            ("\\mathrm", ""),
            ("\\mathbf", ""),
            ("\\vec", ""),
            ("\\hat", ""),
            ("\\bar", ""),
            ("\\dot", ""),
            ("\\ddot", ""),
            ("\\quad", " "),
            ("\\qquad", "  "),
            ("\\,", " "),
            ("\\;", " "),
            ("\\!", ""),
            ("\\hspace", ""),
            ("\\ln", "ln"),
            ("\\log", "log"),
            ("\\sin", "sin"),
            ("\\cos", "cos"),
            ("\\tan", "tan"),
            ("\\sec", "sec"),
            ("\\csc", "csc"),
            ("\\cot", "cot"),
            ("\\arcsin", "arcsin"),
            ("\\arccos", "arccos"),
            ("\\arctan", "arctan"),
            ("\\exp", "exp"),
            ("\\lim", "lim"),
            ("\\max", "max"),
            ("\\min", "min"),
        ]

        for (from, to) in replacements {
            s = s.replacingOccurrences(of: from, with: to)
        }

        // Handle superscripts: ^{...} → superscript chars, ^x → superscript x
        s = replacePattern(in: s, pattern: "\\^\\{([^}]*)\\}") { match in
            superscript(match)
        }
        s = replacePattern(in: s, pattern: "\\^([0-9a-zA-Z])") { match in
            superscript(match)
        }

        // Handle subscripts: _{...} → subscript chars, _x → subscript x
        s = replacePattern(in: s, pattern: "_\\{([^}]*)\\}") { match in
            subscriptText(match)
        }
        s = replacePattern(in: s, pattern: "_([0-9a-zA-Z])") { match in
            subscriptText(match)
        }

        // Remove remaining braces
        s = s.replacingOccurrences(of: "{", with: "")
        s = s.replacingOccurrences(of: "}", with: "")
        s = s.replacingOccurrences(of: "⧹", with: "\\")

        // Clean extra whitespace
        while s.contains("  ") {
            s = s.replacingOccurrences(of: "  ", with: " ")
        }

        return s.trimmingCharacters(in: .whitespaces)
    }

    private func replacePattern(in input: String, pattern: String, replacement: (String) -> String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return input }
        var result = input
        let matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result))
        for match in matches.reversed() {
            guard let fullRange = Range(match.range, in: result),
                  let groupRange = Range(match.range(at: 1), in: result) else { continue }
            let captured = String(result[groupRange])
            result.replaceSubrange(fullRange, with: replacement(captured))
        }
        return result
    }

    private func superscript(_ text: String) -> String {
        let superscriptMap: [Character: Character] = [
            "0": "⁰", "1": "¹", "2": "²", "3": "³", "4": "⁴",
            "5": "⁵", "6": "⁶", "7": "⁷", "8": "⁸", "9": "⁹",
            "+": "⁺", "-": "⁻", "=": "⁼", "(": "⁽", ")": "⁾",
            "n": "ⁿ", "i": "ⁱ", "x": "ˣ", "y": "ʸ",
        ]
        return String(text.map { superscriptMap[$0] ?? $0 })
    }

    private func subscriptText(_ text: String) -> String {
        let subscriptMap: [Character: Character] = [
            "0": "₀", "1": "₁", "2": "₂", "3": "₃", "4": "₄",
            "5": "₅", "6": "₆", "7": "₇", "8": "₈", "9": "₉",
            "+": "₊", "-": "₋", "=": "₌", "(": "₍", ")": "₎",
            "a": "ₐ", "e": "ₑ", "o": "ₒ", "x": "ₓ",
            "i": "ᵢ", "j": "ⱼ", "k": "ₖ", "n": "ₙ", "r": "ᵣ",
        ]
        return String(text.map { subscriptMap[$0] ?? $0 })
    }

    // MARK: - Fraction & Sqrt Pre-processing

    /// Replace \frac{num}{den} → (num)/(den), handles nested fractions iteratively
    private func processFractions(_ input: String) -> String {
        var s = input
        let pattern = "\\\\frac\\{([^{}]*)\\}\\{([^{}]*)\\}"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return s }
        var found = true
        var iterations = 0
        while found && iterations < 10 {
            iterations += 1
            let matches = regex.matches(in: s, range: NSRange(s.startIndex..., in: s))
            if matches.isEmpty { found = false; break }
            for match in matches.reversed() {
                guard let fullRange = Range(match.range, in: s),
                      let numRange = Range(match.range(at: 1), in: s),
                      let denRange = Range(match.range(at: 2), in: s) else { continue }
                let num = String(s[numRange])
                let den = String(s[denRange])
                let numStr = num.count > 1 ? "(\(num))" : num
                let denStr = den.count > 1 ? "(\(den))" : den
                s.replaceSubrange(fullRange, with: "\(numStr)/\(denStr)")
            }
        }
        return s
    }

    /// Replace \sqrt{expr} → √(expr)
    private func processSqrt(_ input: String) -> String {
        var s = input
        let pattern = "\\\\sqrt\\{([^{}]*)\\}"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return s }
        var found = true
        var iterations = 0
        while found && iterations < 10 {
            iterations += 1
            let matches = regex.matches(in: s, range: NSRange(s.startIndex..., in: s))
            if matches.isEmpty { found = false; break }
            for match in matches.reversed() {
                guard let fullRange = Range(match.range, in: s),
                      let groupRange = Range(match.range(at: 1), in: s) else { continue }
                let expr = String(s[groupRange])
                s.replaceSubrange(fullRange, with: "√(\(expr))")
            }
        }
        return s
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        LaTeXTextView(latex: "x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}")
        LaTeXTextView(latex: "E = mc^2")
        LaTeXTextView(latex: "\\int_a^b f(x)\\,dx = F(b) - F(a)")
        LaTeXTextView(latex: "\\nabla \\times \\vec{E} = -\\frac{\\partial \\vec{B}}{\\partial t}")
        LaTeXTextView(latex: "PV = nRT")
        LaTeXTextView(latex: "F = G\\frac{m_1 m_2}{r^2}")
    }
    .padding()
}
