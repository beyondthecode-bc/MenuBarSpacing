import SwiftUI

struct PresetPicker: View {
    @Bindable var defaults: SpacingDefaults

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "PRESETS"))
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                ForEach(SpacingPreset.allCases) { preset in
                    let isSelected = defaults.matchingPreset == preset

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            defaults.applyPreset(preset)
                        }
                    } label: {
                        VStack(spacing: 2) {
                            Text(preset.label)
                                .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                            Text(preset.description)
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(isSelected
                                      ? Color.accentColor.opacity(0.15)
                                      : Color.primary.opacity(0.04))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .strokeBorder(isSelected
                                              ? Color.accentColor.opacity(0.4)
                                              : Color.primary.opacity(0.08),
                                              lineWidth: isSelected ? 1.5 : 0.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
