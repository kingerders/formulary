import SwiftUI
import Combine

/// Reusable parameter slider with label, value display, unit badge, and debounced binding
struct ParameterSliderView: View {
    let label: String
    let symbol: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 0.1
    var unit: String = ""
    var color: Color = .appPrimary
    var decimalPlaces: Int = 1

    @State private var isDragging = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                // Symbol
                Text(symbol)
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundStyle(color)
                    .frame(width: 24)

                Text(label)
                    .font(.qCaption)
                    .foregroundStyle(.secondary)

                Spacer()

                // Value badge
                HStack(spacing: 2) {
                    Text(String(format: "%.\(decimalPlaces)f", value))
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(color)
                    if !unit.isEmpty {
                        Text(unit)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }

            Slider(value: $value, in: range, step: step) {
                EmptyView()
            } onEditingChanged: { editing in
                isDragging = editing
                if editing {
                    HapticFeedback.selection()
                }
            }
            .tint(color)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(String(format: "%.\(decimalPlaces)f", value)) \(unit)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                value = min(value + step, range.upperBound)
            case .decrement:
                value = max(value - step, range.lowerBound)
            @unknown default: break
            }
        }
    }
}

/// Playback controls for animations (play/pause/speed/reset)
struct PlaybackControlView: View {
    @Binding var isPlaying: Bool
    @Binding var speed: Double
    var onReset: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Reset
            Button {
                onReset()
                HapticFeedback.light()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            // Play/Pause
            Button {
                isPlaying.toggle()
                HapticFeedback.selection()
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.appPrimary)
                    .frame(width: 44, height: 44)
                    .background(Color.appPrimary.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .symbolEffect(.bounce, value: isPlaying)

            // Speed
            Menu {
                ForEach([0.25, 0.5, 1.0, 2.0], id: \.self) { s in
                    Button {
                        speed = s
                    } label: {
                        Label("\(s, specifier: "%.2g")×", systemImage: speed == s ? "checkmark" : "")
                    }
                }
            } label: {
                HStack(spacing: 3) {
                    Text("\(speed, specifier: "%.2g")×")
                        .font(.qCaption)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 8, weight: .bold))
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.tertiarySystemFill))
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

/// Container card for a visualization with header badge and expand button
struct VisualizationCard<Content: View>: View {
    let entry: VisualizationEntry
    @ViewBuilder let content: () -> Content
    @Environment(\.colorScheme) private var colorScheme
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 10) {
                Image(systemName: entry.type.icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 26, height: 26)
                    .background(badgeColor.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

                Text(entry.title)
                    .font(.qCaption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("📊 Interactive")
                    .font(.qCaption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.appAccent.opacity(0.15))
                    .foregroundStyle(Color.appAccent)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, isExpanded ? 8 : 16)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.35)) { isExpanded.toggle() }
            }

            if isExpanded {
                content()
                    .padding(.horizontal, 12)
                    .padding(.bottom, 16)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity
                    ))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(colorScheme == .dark ? Color(.secondarySystemGroupedBackground) : .white)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        .onAppear { isExpanded = true } // auto-expand
    }

    private var badgeColor: Color {
        switch entry.type {
        case .parameterGraph: return .blue
        case .geometric: return .orange
        case .process: return .green
        case .vectorField: return .purple
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ParameterSliderView(
            label: "Coefficient", symbol: "a",
            value: .constant(2.0),
            range: -5...5,
            color: .red
        )

        PlaybackControlView(isPlaying: .constant(false), speed: .constant(1.0), onReset: {})
    }
    .padding()
}
