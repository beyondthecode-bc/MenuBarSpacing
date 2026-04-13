import AppKit
import Foundation
import os

enum GitHubUpdateChecker {

    enum UpdateResult {
        case upToDate
        case available(version: String, downloadURL: URL)
    }

    private static let logger = Logger(subsystem: "com.beyondthecode.menubarspacing", category: "updater")

    private static let repoOwner = "beyondthecode-bc"
    private static let repoName = "MenuBarSpacing"

    static func checkForUpdate(currentVersion: String) async throws -> UpdateResult {
        let url = URL(string: "https://api.github.com/repos/\(repoOwner)/\(repoName)/releases/latest")!
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw UpdateError.serverError
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let tagName = json["tag_name"] as? String else {
            throw UpdateError.invalidResponse
        }

        let latestVersion = tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName

        guard isNewer(latestVersion, than: currentVersion) else {
            return .upToDate
        }

        guard let assets = json["assets"] as? [[String: Any]],
              let zipAsset = assets.first(where: { ($0["name"] as? String)?.hasSuffix(".zip") == true }),
              let downloadURLString = zipAsset["browser_download_url"] as? String,
              let downloadURL = URL(string: downloadURLString) else {
            if let htmlURL = json["html_url"] as? String, let url = URL(string: htmlURL) {
                return .available(version: latestVersion, downloadURL: url)
            }
            throw UpdateError.noDownloadAsset
        }

        return .available(version: latestVersion, downloadURL: downloadURL)
    }

    static func downloadUpdate(from url: URL, progress: @escaping (Double) -> Void) async throws -> String {
        let (tempURL, response) = try await URLSession.shared.download(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw UpdateError.downloadFailed
        }

        let dest = FileManager.default.temporaryDirectory
            .appendingPathComponent("MenuBarSpacing-update.zip")
        if FileManager.default.fileExists(atPath: dest.path) {
            try FileManager.default.removeItem(at: dest)
        }
        try FileManager.default.moveItem(at: tempURL, to: dest)

        progress(1.0)
        logger.info("Update downloaded to \(dest.path, privacy: .public)")
        return dest.path
    }

    static func installUpdate(fromZip zipPath: String) async throws {
        let zipURL = URL(fileURLWithPath: zipPath)
        let extractDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("MenuBarSpacing-extract")

        if FileManager.default.fileExists(atPath: extractDir.path) {
            try FileManager.default.removeItem(at: extractDir)
        }
        try FileManager.default.createDirectory(at: extractDir, withIntermediateDirectories: true)

        let unzip = Process()
        unzip.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
        unzip.arguments = ["-xk", zipURL.path, extractDir.path]
        try unzip.run()
        unzip.waitUntilExit()
        guard unzip.terminationStatus == 0 else {
            throw UpdateError.extractFailed
        }

        let contents = try FileManager.default.contentsOfDirectory(at: extractDir, includingPropertiesForKeys: nil)
        guard let appBundle = contents.first(where: { $0.pathExtension == "app" }) else {
            throw UpdateError.noAppInArchive
        }

        let currentApp = Bundle.main.bundleURL
        let appDir = currentApp.deletingLastPathComponent()
        let destURL = appDir.appendingPathComponent(appBundle.lastPathComponent)

        let xattr = Process()
        xattr.executableURL = URL(fileURLWithPath: "/usr/bin/xattr")
        xattr.arguments = ["-dr", "com.apple.quarantine", appBundle.path]
        try? xattr.run()
        xattr.waitUntilExit()

        func shellEscape(_ path: String) -> String {
            "'" + path.replacingOccurrences(of: "'", with: "'\\''") + "'"
        }
        let src = shellEscape(appBundle.path)
        let dst = shellEscape(destURL.path)
        let script = "do shell script \"rm -rf \(dst) && cp -R \(src) \(dst)\" with administrator privileges"

        var appleScriptError: NSDictionary?
        guard let appleScript = NSAppleScript(source: script) else {
            throw UpdateError.installFailed("Could not create installer script")
        }
        appleScript.executeAndReturnError(&appleScriptError)
        if let err = appleScriptError {
            let msg = err[NSAppleScript.errorMessage] as? String ?? "Unknown error"
            if msg.lowercased().contains("cancel") {
                throw UpdateError.installFailed("Authorization cancelled")
            }
            throw UpdateError.installFailed(msg)
        }

        let open = Process()
        open.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        open.arguments = ["-n", destURL.path]
        try open.run()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            NSApplication.shared.terminate(nil)
        }
    }

    private static func isNewer(_ candidate: String, than current: String) -> Bool {
        let lhs = candidate.split(separator: ".").compactMap { Int($0) }
        let rhs = current.split(separator: ".").compactMap { Int($0) }
        let count = max(lhs.count, rhs.count)
        for i in 0..<count {
            let a = i < lhs.count ? lhs[i] : 0
            let b = i < rhs.count ? rhs[i] : 0
            if a != b { return a > b }
        }
        return false
    }

    enum UpdateError: LocalizedError {
        case serverError
        case invalidResponse
        case noDownloadAsset
        case downloadFailed
        case extractFailed
        case noAppInArchive
        case installFailed(String)

        var errorDescription: String? {
            switch self {
            case .serverError: return "Could not reach GitHub. Check your internet connection."
            case .invalidResponse: return "Unexpected response from GitHub."
            case .noDownloadAsset: return "No download found in the latest release."
            case .downloadFailed: return "Download failed."
            case .extractFailed: return "Could not extract the update archive."
            case .noAppInArchive: return "No app found in the downloaded archive."
            case .installFailed(let msg): return "Install failed: \(msg)"
            }
        }
    }
}
