import SwiftUI

struct ApplySection: View {
    @Bindable var defaults: SpacingDefaults
    @State private var saved = false
    @State private var showRebootConfirm = false
    @State private var showLogoutConfirm = false

    var body: some View {
        VStack(spacing: 14) {
            // Info box
            Label(
                String(localized: "Menu bar spacing changes require a reboot or logout to take effect. This is a macOS limitation."),
                systemImage: "info.circle"
            )
            .font(.system(size: 11))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.blue.opacity(0.06))
            )

            // Primary action: Apply & Reboot
            Button {
                showRebootConfirm = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.trianglehead.2.clockwise")
                    Text(String(localized: "Apply & Reboot"))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!defaults.isDirty && !saved)
            .confirmationDialog(
                String(localized: "Reboot to apply spacing changes?"),
                isPresented: $showRebootConfirm,
                titleVisibility: .visible
            ) {
                Button(String(localized: "Apply & Reboot"), role: .destructive) {
                    defaults.apply()
                    MenuBarRestart.reboot()
                }
                Button(String(localized: "Cancel"), role: .cancel) {}
            } message: {
                Text(String(localized: "Save your work in all apps before rebooting."))
            }

            HStack(spacing: 12) {
                // Secondary: Apply & Log Out
                Button {
                    showLogoutConfirm = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 10))
                        Text(String(localized: "Apply & Log Out"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.bordered)
                .disabled(!defaults.isDirty && !saved)
                .confirmationDialog(
                    String(localized: "Log out to apply spacing changes?"),
                    isPresented: $showLogoutConfirm,
                    titleVisibility: .visible
                ) {
                    Button(String(localized: "Apply & Log Out"), role: .destructive) {
                        defaults.apply()
                        MenuBarRestart.logout()
                    }
                    Button(String(localized: "Cancel"), role: .cancel) {}
                } message: {
                    Text(String(localized: "Save your work in all apps before logging out."))
                }

                // Save without restart
                Button {
                    defaults.apply()
                    saved = true
                } label: {
                    Text(String(localized: "Save Only"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.bordered)
                .disabled(!defaults.isDirty)
            }

            // Reset to macOS default
            Button {
                defaults.reset()
                saved = false
            } label: {
                Text(String(localized: "Reset to Default"))
                    .font(.system(size: 11))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .disabled(defaults.isDefault)

            if saved {
                Label(
                    String(localized: "Settings saved. Reboot or log out to apply."),
                    systemImage: "checkmark.circle.fill"
                )
                .font(.system(size: 11))
                .foregroundStyle(.green)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: saved)
    }
}
