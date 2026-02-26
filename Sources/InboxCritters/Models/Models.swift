import Foundation

// MARK: - Bucket / Priority

enum Bucket: Int, CaseIterable, Codable {
    case mit      = 0   // Most Important Task
    case high     = 1
    case normal   = 2
    case someday  = 3

    var label: String {
        switch self {
        case .mit:     return "MIT"
        case .high:    return "High"
        case .normal:  return "Normal"
        case .someday: return "Someday"
        }
    }

    var emoji: String {
        switch self {
        case .mit:     return "🔴"
        case .high:    return "🟡"
        case .normal:  return "🟢"
        case .someday: return "🔵"
        }
    }

    var color: (r: Double, g: Double, b: Double) {
        switch self {
        case .mit:     return (0.90, 0.22, 0.22)
        case .high:    return (0.95, 0.75, 0.10)
        case .normal:  return (0.22, 0.80, 0.38)
        case .someday: return (0.22, 0.55, 0.95)
        }
    }
}

// MARK: - Thought Orb

struct ThoughtOrb: Identifiable, Equatable {
    let id:   UUID
    let text: String

    init(text: String) {
        id        = UUID()
        self.text = text
    }
}

// MARK: - Sorted Thought

struct SortedThought: Identifiable, Codable {
    let id:     UUID
    let text:   String
    let bucket: Bucket
    let date:   Date

    init(text: String, bucket: Bucket) {
        id         = UUID()
        self.text  = text
        self.bucket = bucket
        date       = Date()
    }
}

// MARK: - Critter kind

enum CritterKind: CaseIterable {
    case mouse, mosquito, worm

    var emoji: String {
        switch self {
        case .mouse:    return "🐭"
        case .mosquito: return "🦟"
        case .worm:     return "🐛"
        }
    }
}
