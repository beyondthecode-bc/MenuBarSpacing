import SwiftUI

struct MenuBarPreview: View {
    let spacing: Int
    let padding: Int

    private let icons = [
        "wifi", "personalhotspot", "battery.75percent",
        "speaker.wave.2.fill", "clock", "magnifyingglass",
        "bell.fill", "gearshape.fill"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "PREVIEW"))
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(.secondary)

            HStack(spacing: 0) {
                ForEach(Array(icons.enumerated()), id: \.offset) { index, icon in
                    if index > 0 {
                        Spacer()
                            .frame(width: CGFloat(spacing))
                    }

                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.primary.opacity(0.85))
                        .frame(width: 18, height: 18)
                        .padding(.horizontal, CGFloat(padding) / 2)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(Color.accentColor.opacity(0.08))
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .clipped()
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.primary.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
            )

            Text(String(localized: "Approximate representation"))
                .font(.system(size: 9, weight: .regular))
                .foregroundStyle(.tertiary)
        }
    }
}
