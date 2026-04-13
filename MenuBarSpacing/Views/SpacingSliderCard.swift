import SwiftUI

struct SpacingSliderCard: View {
    let title: String
    let symbol: String
    let sublabel: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let systemDefault: Int
    let accentColor: Color

    @State private var sliderValue: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                Image(systemName: symbol)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(accentColor)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .textCase(.uppercase)
                        .tracking(1.5)
                    Text(sublabel)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(value) px")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .monospacedDigit()
                    .foregroundStyle(value == systemDefault ? .secondary : accentColor)
            }

            VStack(spacing: 4) {
                Slider(
                    value: $sliderValue,
                    in: Double(range.lowerBound)...Double(range.upperBound),
                    step: 1
                )
                .tint(accentColor)
                .onChange(of: sliderValue) { _, newValue in
                    value = Int(newValue)
                }

                HStack {
                    Text("\(range.lowerBound) px")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.tertiary)
                    Spacer()
                    Text(String(localized: "default: \(systemDefault) px"))
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.tertiary)
                    Spacer()
                    Text("\(range.upperBound) px")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.background.secondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
        )
        .onAppear { sliderValue = Double(value) }
        .onChange(of: value) { _, newValue in
            if Int(sliderValue) != newValue {
                sliderValue = Double(newValue)
            }
        }
    }
}
