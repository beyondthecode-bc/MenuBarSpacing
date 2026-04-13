import SwiftUI

struct ContentView: View {
    @Bindable var defaults: SpacingDefaults

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(String(localized: "Menu Bar Spacing"))
                        .font(.system(size: 20, weight: .semibold, design: .rounded))

                    Text("v1.0.0")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule().fill(Color.primary.opacity(0.06))
                        )

                    Spacer()

                    Button {
                        AboutWindow.show()
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help(String(localized: "About Menu Bar Spacing"))
                }

                Text(String(localized: "Adjust the spacing between menu bar icons"))
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)

            Divider()
                .padding(.horizontal, 24)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Live preview
                    MenuBarPreview(spacing: defaults.spacing, padding: defaults.padding)

                    // Presets
                    PresetPicker(defaults: defaults)

                    // Spacing slider
                    SpacingSliderCard(
                        title: String(localized: "Icon Spacing"),
                        symbol: "arrow.left.and.right",
                        sublabel: String(localized: "Gap between menu bar icons"),
                        value: $defaults.spacing,
                        range: SpacingDefaults.spacingRange,
                        systemDefault: SpacingDefaults.systemSpacing,
                        accentColor: .blue
                    )

                    // Link toggle
                    Toggle(isOn: $defaults.linkPadding) {
                        HStack(spacing: 6) {
                            Image(systemName: "link")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                            Text(String(localized: "Link padding to spacing"))
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .toggleStyle(.checkbox)
                    .padding(.leading, 4)
                    .padding(.top, -10)

                    // Padding slider
                    SpacingSliderCard(
                        title: String(localized: "Selection Padding"),
                        symbol: "rectangle.dashed",
                        sublabel: String(localized: "Clickable area around each icon"),
                        value: $defaults.padding,
                        range: SpacingDefaults.paddingRange,
                        systemDefault: SpacingDefaults.systemPadding,
                        accentColor: .indigo
                    )
                    .disabled(defaults.linkPadding)
                    .opacity(defaults.linkPadding ? 0.5 : 1.0)

                    Divider()

                    // Apply / Reset
                    ApplySection(defaults: defaults)
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 24)
            }
        }
        .padding(.horizontal, 8)
        .frame(width: 540, height: 620)
        .background(.background)
        .fixedSize()
    }
}
