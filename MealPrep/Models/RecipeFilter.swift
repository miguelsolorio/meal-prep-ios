import Foundation

enum SortOrder: String, CaseIterable, Identifiable {
    case dateAdded = "Date Added"
    case name = "Name"
    case cookTime = "Cook Time"

    var id: String { rawValue }
    var displayName: String { rawValue }
}

enum CookTimeFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case under30 = "Under 30 min"
    case under60 = "Under 1 hour"
    case over60 = "Over 1 hour"

    var id: String { rawValue }
    var displayName: String { rawValue }

    func matches(totalMinutes: Int) -> Bool {
        switch self {
        case .all: return true
        case .under30: return totalMinutes > 0 && totalMinutes < 30
        case .under60: return totalMinutes > 0 && totalMinutes < 60
        case .over60: return totalMinutes >= 60
        }
    }
}

enum SelectionFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case selected = "Selected"
    case unselected = "Unselected"

    var id: String { rawValue }
    var displayName: String { rawValue }
}

struct FilterOptions {
    var sortOrder: SortOrder = .dateAdded
    var cookTimeFilter: CookTimeFilter = .all
    var selectionFilter: SelectionFilter = .all

    var isDefault: Bool {
        sortOrder == .dateAdded && cookTimeFilter == .all && selectionFilter == .all
    }
}
