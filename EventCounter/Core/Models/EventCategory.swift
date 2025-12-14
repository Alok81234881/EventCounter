import Foundation

enum EventCategory: String, Codable, CaseIterable {
    case birthday
    case travel
    case exam
    case launch
    case personal
    
    var icon: String {
        switch self {
        case .birthday: return "cake"
        case .travel: return "airplane"
        case .exam: return "book.closed"
        case .launch: return "rocket"
        case .personal: return "person"
        }
    }
    
    var displayName: String {
        rawValue.capitalized
    }
}
