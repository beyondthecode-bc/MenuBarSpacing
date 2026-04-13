import Foundation

enum SpacingPreset: String, CaseIterable, Identifiable {
    case compact
    case tight
    case standard
    case comfortable
    case spacious

    var id: String { rawValue }

    var spacing: Int {
        switch self {
        case .compact:     return 6
        case .tight:       return 12
        case .standard:    return 17
        case .comfortable: return 22
        case .spacious:    return 28
        }
    }

    var padding: Int {
        switch self {
        case .compact:     return 4
        case .tight:       return 8
        case .standard:    return 11
        case .comfortable: return 14
        case .spacious:    return 18
        }
    }

    var label: String {
        switch self {
        case .compact:     return String(localized: "Compact")
        case .tight:       return String(localized: "Tight")
        case .standard:    return String(localized: "Default")
        case .comfortable: return String(localized: "Comfortable")
        case .spacious:    return String(localized: "Spacious")
        }
    }

    var description: String {
        switch self {
        case .compact:     return String(localized: "Maximum density")
        case .tight:       return String(localized: "Reduced gaps")
        case .standard:    return String(localized: "macOS default")
        case .comfortable: return String(localized: "Extra room")
        case .spacious:    return String(localized: "Wide gaps")
        }
    }
}
