import SwiftUI

struct AboutView: View {
    @State private var updateState: UpdateCheckState = .idle
    @State private var downloadProgress: Double?
    @State private var selectedLanguage: String = {
        if let overrides = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String],
           let first = overrides.first {
            let supported = ["en", "fr", "de", "es", "ja", "ko", "pt-BR", "zh-Hans"]
            if supported.contains(first) { return first }
            let prefix = String(first.prefix(2))
            if supported.contains(prefix) { return prefix }
        }
        return "system"
    }()
    @State private var showRestartAlert = false

    private let repoURL: URL = {
        let raw = Bundle.main.object(forInfoDictionaryKey: "GitHubRepositoryURL") as? String
        return URL(string: raw ?? "https://github.com/beyondthecode-bc/MenuBarSpacing")
            ?? URL(string: "https://github.com/beyondthecode-bc/MenuBarSpacing")!
    }()

    private var shortVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
    }

    private var bundleName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Menu Bar Spacing"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                // Banner
                Image("AboutBanner")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 140)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.10), radius: 6, y: 2)

                // Version card
                versionCard

                // Updates card
                updatesCard

                // GitHub card
                repoCard

                // Support card
                supportCard

                // Language card
                languageCard
            }
            .padding(24)
        }
        .frame(width: 480, height: 680)
        .background(.background)
    }

    // MARK: - Version card

    private var versionCard: some View {
        cardContainer {
            HStack {
                Image(systemName: "app.badge.fill")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.blue)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 1) {
                    Text("ABOUT")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(.secondary)
                    Text(bundleName)
                        .font(.system(size: 12, weight: .semibold))
                }

                Spacer()

                Text("v\(shortVersion)")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundStyle(.blue)
            }

            Divider()

            VStack(spacing: 8) {
                infoRow(label: "BUILD NAME", value: bundleName)
                infoRow(label: "VERSION", value: shortVersion)
                infoRow(label: "PLATFORM", value: "macOS \(ProcessInfo.processInfo.operatingSystemVersionString)")
            }
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(LocalizedStringKey(label))
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .tracking(1.6)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(.primary.opacity(0.85))
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(.vertical, 2)
    }

    // MARK: - Updates card

    private let updateAccent = Color(red: 0.55, green: 0.80, blue: 0.95)

    private var updatesCard: some View {
        cardContainer {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(updateAccent)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 1) {
                    Text("UPDATES")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(.secondary)
                    Text(updateSublabel)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    checkForUpdatesManually()
                } label: {
                    HStack(spacing: 6) {
                        if case .checking = updateState {
                            ProgressView()
                                .controlSize(.small)
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 11))
                        }
                        Text(String(localized: "Check Now"))
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(updateAccent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(updateAccent.opacity(0.12)))
                    .overlay(Capsule().stroke(updateAccent.opacity(0.35), lineWidth: 0.8))
                }
                .buttonStyle(.plain)
                .disabled(updateState == .checking)
            }

            Divider()

            switch updateState {
            case .idle:
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    Text(String(localized: "Click **Check Now** to look for updates."))
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            case .checking:
                statusRow(icon: "magnifyingglass", text: String(localized: "Checking for updates…"))
            case .upToDate:
                statusRow(
                    icon: "checkmark.circle.fill",
                    text: String(localized: "You're on the latest version (v\(shortVersion))"),
                    tint: .green
                )
            case .available(let latest, let url):
                updateAvailableView(latest: latest, downloadURL: url)
            case .downloading:
                downloadingRow
            case .downloaded(let path):
                downloadedRow(path: path)
            case .error(let msg):
                statusRow(icon: "exclamationmark.triangle.fill", text: msg, tint: .orange)
            }
        }
    }

    private var updateSublabel: String {
        switch updateState {
        case .available: return String(localized: "update available")
        case .downloading: return String(localized: "downloading…")
        case .downloaded: return String(localized: "ready to install")
        default: return "v\(shortVersion)"
        }
    }

    private func statusRow(icon: String, text: String, tint: Color = .secondary) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(tint)
            Text(text)
                .font(.system(size: 11.5, weight: .medium))
                .foregroundStyle(.primary.opacity(0.85))
            Spacer()
        }
    }

    private func updateAvailableView(latest: String, downloadURL: URL) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("INSTALLED")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .tracking(1.4)
                        .foregroundStyle(.secondary)
                    Text("v\(shortVersion)")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.primary)
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.tertiary)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("LATEST")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .tracking(1.4)
                        .foregroundStyle(.secondary)
                    Text("v\(latest)")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundStyle(updateAccent)
                }
            }

            Button {
                downloadUpdate(from: downloadURL)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 12))
                    Text(String(localized: "Download & Install"))
                        .font(.system(size: 12, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(updateAccent.opacity(0.15))
                .foregroundStyle(updateAccent)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(updateAccent.opacity(0.3), lineWidth: 0.8)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var downloadingRow: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                ProgressView()
                    .controlSize(.small)
                Text(String(localized: "Downloading update…"))
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundStyle(.primary.opacity(0.85))
                Spacer()
            }
            if let progress = downloadProgress {
                ProgressView(value: progress)
                    .tint(updateAccent)
            }
        }
    }

    private func downloadedRow(path: String) -> some View {
        VStack(spacing: 10) {
            statusRow(icon: "checkmark.circle.fill", text: String(localized: "Update downloaded and ready"), tint: .green)

            Button {
                installDownloadedUpdate(at: path)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.uturn.forward.circle.fill")
                        .font(.system(size: 12))
                    Text(String(localized: "Install Now"))
                        .font(.system(size: 12, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.15))
                .foregroundStyle(.green)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.green.opacity(0.3), lineWidth: 0.8)
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Update logic

    private func checkForUpdatesManually() {
        updateState = .checking
        Task {
            do {
                let result = try await GitHubUpdateChecker.checkForUpdate(currentVersion: shortVersion)
                await MainActor.run {
                    switch result {
                    case .upToDate:
                        updateState = .upToDate
                    case .available(let version, let url):
                        updateState = .available(latestVersion: version, downloadURL: url)
                    }
                }
            } catch {
                await MainActor.run {
                    updateState = .error(error.localizedDescription)
                }
            }
        }
    }

    private func downloadUpdate(from url: URL) {
        updateState = .downloading
        downloadProgress = nil
        Task {
            do {
                let path = try await GitHubUpdateChecker.downloadUpdate(from: url) { @Sendable progress in
                    Task { @MainActor in
                        self.downloadProgress = progress
                    }
                }
                await MainActor.run {
                    updateState = .downloaded(path: path)
                }
            } catch {
                await MainActor.run {
                    updateState = .error(String(localized: "Download failed: \(error.localizedDescription)"))
                }
            }
        }
    }

    private func installDownloadedUpdate(at zipPath: String) {
        Task {
            do {
                try await GitHubUpdateChecker.installUpdate(fromZip: zipPath)
            } catch {
                await MainActor.run {
                    updateState = .error(String(localized: "Install failed: \(error.localizedDescription)"))
                }
            }
        }
    }

    // MARK: - GitHub card

    private var repoCard: some View {
        cardContainer {
            HStack {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(red: 0.75, green: 0.75, blue: 0.80))
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 1) {
                    Text("SOURCE")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(.secondary)
                    Text(String(localized: "view on GitHub"))
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Divider()

            VStack(spacing: 14) {
                Text(String(localized: "Visit the GitHub repository to file issues, request features, and follow development."))
                    .font(.system(size: 12))
                    .foregroundStyle(.primary.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .fixedSize(horizontal: false, vertical: true)

                GitHubLinkButton(url: repoURL)
                    .frame(maxWidth: .infinity)

                Text(repoURL.absoluteString)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Support card

    private let buyMeACoffeeURL = URL(string: "https://www.buymeacoffee.com/BEYONDTHECODE")!
    private let githubSponsorsURL = URL(string: "https://github.com/sponsors/beyondthecode-bc")!

    private var supportCard: some View {
        cardContainer {
            HStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.pink)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 1) {
                    Text("SUPPORT")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(.secondary)
                    Text(String(localized: "help keep this project alive"))
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Divider()

            Text(String(localized: "If you find Menu Bar Spacing useful, consider supporting its development."))
                .font(.system(size: 12))
                .foregroundStyle(.primary.opacity(0.75))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                // Buy Me a Coffee
                Link(destination: buyMeACoffeeURL) {
                    HStack(spacing: 8) {
                        BuyMeACoffeeIcon()
                            .frame(width: 18, height: 18)
                        Text("Buy Me a Coffee")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(red: 1.0, green: 0.87, blue: 0.0).opacity(0.15))
                    .foregroundStyle(Color(red: 0.85, green: 0.65, blue: 0.0))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color(red: 1.0, green: 0.87, blue: 0.0).opacity(0.35), lineWidth: 0.8)
                    )
                }
                .buttonStyle(.plain)

                // GitHub Sponsors
                Link(destination: githubSponsorsURL) {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 16))
                        Text("GitHub Sponsors")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.pink.opacity(0.12))
                    .foregroundStyle(.pink)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.pink.opacity(0.3), lineWidth: 0.8)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Language card

    private var languageCard: some View {
        cardContainer {
            HStack {
                Image(systemName: "character.bubble")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.purple)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 1) {
                    Text("LANGUAGE")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(.secondary)
                    Text(String(localized: "interface language"))
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Picker("", selection: $selectedLanguage) {
                    Text("System Default").tag("system")
                    Text("English").tag("en")
                    Text("Français").tag("fr")
                    Text("Deutsch").tag("de")
                    Text("Español").tag("es")
                    Text("日本語").tag("ja")
                    Text("한국어").tag("ko")
                    Text("Português").tag("pt-BR")
                    Text("简体中文").tag("zh-Hans")
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .frame(maxWidth: 180)
                .onChange(of: selectedLanguage) { _, newValue in
                    applyLanguage(newValue)
                }
            }

            Divider()

            Text(String(localized: "Choose the display language for Menu Bar Spacing. The app will restart to apply the change."))
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .alert(String(localized: "Restart Required"), isPresented: $showRestartAlert) {
            Button(String(localized: "Restart Now")) { restartApp() }
            Button(String(localized: "Later"), role: .cancel) { }
        } message: {
            Text(String(localized: "Menu Bar Spacing needs to restart to apply the new language."))
        }
    }

    private func applyLanguage(_ code: String) {
        if code == "system" {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.set([code], forKey: "AppleLanguages")
        }
        UserDefaults.standard.synchronize()
        showRestartAlert = true
    }

    private func restartApp() {
        let url = URL(fileURLWithPath: Bundle.main.bundlePath)
        let config = NSWorkspace.OpenConfiguration()
        config.createsNewApplicationInstance = true
        NSWorkspace.shared.openApplication(at: url, configuration: config)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NSApp.terminate(nil)
        }
    }

    // MARK: - Card container

    @ViewBuilder
    private func cardContainer(@ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
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
    }
}

// MARK: - Update check state

enum UpdateCheckState: Equatable {
    case idle
    case checking
    case upToDate
    case available(latestVersion: String, downloadURL: URL)
    case downloading
    case downloaded(path: String)
    case error(String)

    static func == (lhs: UpdateCheckState, rhs: UpdateCheckState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.checking, .checking), (.upToDate, .upToDate), (.downloading, .downloading):
            return true
        case (.available(let a, _), .available(let b, _)):
            return a == b
        case (.downloaded(let a), .downloaded(let b)):
            return a == b
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}

// MARK: - GitHub logo shape

private struct GitHubLogoShape: Shape {
    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height)
        let ox = rect.midX - s / 2
        let oy = rect.midY - s / 2
        func p(_ x: Double, _ y: Double) -> CGPoint {
            CGPoint(x: ox + x / 16 * s, y: oy + y / 16 * s)
        }
        var path = Path()
        path.move(to: p(8, 0))
        path.addCurve(to: p(0, 8), control1: p(3.58, 0), control2: p(0, 3.58))
        path.addCurve(to: p(5.46, 15.56), control1: p(0, 11.54), control2: p(2.29, 14.27))
        path.addCurve(to: p(6, 14.65), control1: p(5.73, 15.63), control2: p(6, 15.24))
        path.addLine(to: p(6, 13.13))
        path.addCurve(to: p(2.73, 12.1), control1: p(3.78, 13.37), control2: p(2.73, 13.37))
        path.addCurve(to: p(2, 10.7), control1: p(2.73, 11.55), control2: p(2.38, 11.13))
        path.addCurve(to: p(3.44, 10.44), control1: p(1.35, 9.98), control2: p(3.44, 10.44))
        path.addCurve(to: p(4, 11.7), control1: p(3.44, 10.44), control2: p(3.69, 11.2))
        path.addCurve(to: p(6.63, 12.64), control1: p(4.53, 12.56), control2: p(5.64, 12.84))
        path.addCurve(to: p(6.82, 11.78), control1: p(6.6, 12.19), control2: p(6.68, 11.96))
        path.addCurve(to: p(3.97, 8.73), control1: p(4.53, 11.32), control2: p(3.97, 10.23))
        path.addCurve(to: p(4.73, 6.65), control1: p(3.97, 7.95), control2: p(4.25, 7.26))
        path.addCurve(to: p(4.77, 4.68), control1: p(4.59, 6.29), control2: p(4.14, 5.27))
        path.addCurve(to: p(6.58, 5.28), control1: p(4.77, 4.68), control2: p(5.49, 4.75))
        path.addCurve(to: p(8, 5.06), control1: p(7.07, 5.14), control2: p(7.49, 5.06))
        path.addCurve(to: p(9.42, 5.28), control1: p(8.51, 5.06), control2: p(8.93, 5.14))
        path.addCurve(to: p(11.23, 4.68), control1: p(10.51, 4.75), control2: p(11.23, 4.68))
        path.addCurve(to: p(11.27, 6.65), control1: p(11.86, 5.27), control2: p(11.41, 6.29))
        path.addCurve(to: p(12.03, 8.73), control1: p(11.75, 7.26), control2: p(12.03, 7.95))
        path.addCurve(to: p(9.18, 11.78), control1: p(12.03, 10.23), control2: p(11.47, 11.32))
        path.addCurve(to: p(9.5, 12.63), control1: p(9.36, 12.01), control2: p(9.5, 12.28))
        path.addLine(to: p(9.5, 14.65))
        path.addCurve(to: p(10, 15.56), control1: p(9.5, 15.03), control2: p(9.66, 15.38))
        path.addLine(to: p(10.54, 15.56))
        path.addCurve(to: p(16, 8), control1: p(13.71, 14.27), control2: p(16, 11.54))
        path.addCurve(to: p(8, 0), control1: p(16, 3.58), control2: p(12.42, 0))
        path.closeSubpath()
        return path
    }
}

// MARK: - GitHub link button

private struct GitHubLinkButton: View {
    let url: URL
    @State private var hover = false

    var body: some View {
        Link(destination: url) {
            ZStack {
                Circle()
                    .fill(Color.primary.opacity(hover ? 0.10 : 0.05))
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [
                                Color.primary.opacity(0.20),
                                Color.primary.opacity(0.05),
                                Color.primary.opacity(0.20)
                            ],
                            center: .center
                        ),
                        lineWidth: 1
                    )
                GitHubLogoShape()
                    .fill(Color.primary.opacity(hover ? 1.0 : 0.75))
                    .frame(width: 26, height: 26)
            }
            .frame(width: 56, height: 56)
            .shadow(color: .black.opacity(hover ? 0.25 : 0.15), radius: hover ? 8 : 4, y: 2)
            .scaleEffect(hover ? 1.06 : 1.0)
            .animation(.easeOut(duration: 0.2), value: hover)
        }
        .buttonStyle(.plain)
        .onHover { hover = $0 }
        .accessibilityLabel(String(localized: "Open Menu Bar Spacing GitHub repository"))
    }
}

// MARK: - Buy Me a Coffee icon

private struct BuyMeACoffeeIcon: View {
    var body: some View {
        BuyMeACoffeeShape()
            .fill(Color(red: 0.85, green: 0.65, blue: 0.0))
    }
}

private struct BuyMeACoffeeShape: Shape {
    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height)
        let ox = rect.midX - s / 2
        let oy = rect.midY - s / 2
        func p(_ x: Double, _ y: Double) -> CGPoint {
            CGPoint(x: ox + x / 24 * s, y: oy + y / 24 * s)
        }
        var path = Path()
        // Cup body
        path.move(to: p(4, 6))
        path.addLine(to: p(5, 20))
        path.addQuadCurve(to: p(7, 22), control: p(5, 22))
        path.addLine(to: p(15, 22))
        path.addQuadCurve(to: p(17, 20), control: p(17, 22))
        path.addLine(to: p(18, 6))
        path.closeSubpath()
        // Handle
        path.move(to: p(18, 8))
        path.addQuadCurve(to: p(18, 15), control: p(22, 11.5))
        // Steam (left)
        path.move(to: p(8, 5))
        path.addQuadCurve(to: p(8, 1), control: p(6, 3))
        // Steam (right)
        path.move(to: p(14, 5))
        path.addQuadCurve(to: p(14, 1), control: p(12, 3))
        return path
    }
}
