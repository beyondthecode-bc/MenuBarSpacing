@preconcurrency import Foundation

@Observable
final class SpacingDefaults {

    // MARK: - Keys

    private static nonisolated(unsafe) let spacingKey = "NSStatusItemSpacing" as CFString
    private static nonisolated(unsafe) let paddingKey = "NSStatusItemSelectionPadding" as CFString

    // MARK: - System defaults (clean macOS install values)

    static let systemSpacing = 17
    static let systemPadding = 11
    static let spacingRange = 0...30
    static let paddingRange = 0...20

    // MARK: - State

    var spacing: Int {
        didSet {
            if linkPadding { syncPaddingToSpacing() }
        }
    }
    var padding: Int
    var linkPadding: Bool = true

    /// Values currently applied in CFPreferences (nil = system default).
    private var appliedSpacing: Int?
    private var appliedPadding: Int?

    var isDirty: Bool {
        spacing != (appliedSpacing ?? Self.systemSpacing) ||
        padding != (appliedPadding ?? Self.systemPadding)
    }

    var isDefault: Bool {
        appliedSpacing == nil && appliedPadding == nil
    }

    // MARK: - Init

    init() {
        // Read from currentHost first (primary, what Clamper/TighterMenubar use),
        // fall back to anyHost (what `defaults write -g` uses).
        let s = Self.readKey(Self.spacingKey, host: kCFPreferencesCurrentHost)
                ?? Self.readKey(Self.spacingKey, host: kCFPreferencesAnyHost)
        let p = Self.readKey(Self.paddingKey, host: kCFPreferencesCurrentHost)
                ?? Self.readKey(Self.paddingKey, host: kCFPreferencesAnyHost)
        self.appliedSpacing = s
        self.appliedPadding = p
        self.spacing = s ?? Self.systemSpacing
        self.padding = p ?? Self.systemPadding
    }

    // MARK: - Apply

    func apply() {
        // Write to BOTH domains for maximum compatibility.
        // macOS reads from currentHost (ByHost plist); write to anyHost too
        // so `defaults read -g` also reflects the values.
        Self.writeKey(Self.spacingKey, value: spacing)
        Self.writeKey(Self.paddingKey, value: padding)
        Self.synchronize()
        appliedSpacing = spacing
        appliedPadding = padding
    }

    func reset() {
        Self.deleteKey(Self.spacingKey)
        Self.deleteKey(Self.paddingKey)
        Self.synchronize()
        appliedSpacing = nil
        appliedPadding = nil
        spacing = Self.systemSpacing
        padding = Self.systemPadding
    }

    func applyPreset(_ preset: SpacingPreset) {
        spacing = preset.spacing
        padding = preset.padding
    }

    var matchingPreset: SpacingPreset? {
        SpacingPreset.allCases.first { $0.spacing == spacing && $0.padding == padding }
    }

    // MARK: - Linked padding

    private func syncPaddingToSpacing() {
        let ratio = Double(Self.systemPadding) / Double(Self.systemSpacing)
        padding = max(Self.paddingRange.lowerBound,
                      min(Self.paddingRange.upperBound,
                          Int(round(Double(spacing) * ratio))))
    }

    // MARK: - CFPreferences (dual-domain: currentHost + anyHost)

    private static func readKey(_ key: CFString, host: CFString) -> Int? {
        let value = CFPreferencesCopyValue(
            key,
            kCFPreferencesAnyApplication,
            kCFPreferencesCurrentUser,
            host
        )
        return (value as? NSNumber)?.intValue
    }

    /// Writes to both currentHost (ByHost, what macOS reads) and anyHost
    /// (NSGlobalDomain, what `defaults read -g` shows).
    private static func writeKey(_ key: CFString, value: Int) {
        let cfValue = value as CFNumber
        CFPreferencesSetValue(
            key, cfValue,
            kCFPreferencesAnyApplication,
            kCFPreferencesCurrentUser,
            kCFPreferencesCurrentHost
        )
        CFPreferencesSetValue(
            key, cfValue,
            kCFPreferencesAnyApplication,
            kCFPreferencesCurrentUser,
            kCFPreferencesAnyHost
        )
    }

    /// Deletes from both domains.
    private static func deleteKey(_ key: CFString) {
        CFPreferencesSetValue(
            key, nil,
            kCFPreferencesAnyApplication,
            kCFPreferencesCurrentUser,
            kCFPreferencesCurrentHost
        )
        CFPreferencesSetValue(
            key, nil,
            kCFPreferencesAnyApplication,
            kCFPreferencesCurrentUser,
            kCFPreferencesAnyHost
        )
    }

    private static func synchronize() {
        CFPreferencesSynchronize(
            kCFPreferencesAnyApplication,
            kCFPreferencesCurrentUser,
            kCFPreferencesCurrentHost
        )
        CFPreferencesSynchronize(
            kCFPreferencesAnyApplication,
            kCFPreferencesCurrentUser,
            kCFPreferencesAnyHost
        )
    }
}
