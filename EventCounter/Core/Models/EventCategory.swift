import Foundation

enum EventCategory: String, Codable, CaseIterable {
    case birthday
    case travel
    case exam
    case launch
    case personal
    case wedding
    case work
    case sobriety
    case quitting
    case anniversary
    
    var icon: String {
        switch self {
        case .birthday: return "birthday.cake"
        case .travel: return "airplane"
        case .exam: return "book.closed"
        case .launch: return "rocket.fill"
        case .personal: return "person"
        case .wedding: return "heart.fill"
        case .work: return "briefcase"
        case .sobriety: return "heart.text.square"
        case .quitting: return "nosign"
        case .anniversary: return "star.fill"
        }
    }
    
    var displayName: String {
        rawValue.capitalized
    }
    
    func milestoneDescription(for title: String, time: String) -> String {
        switch self {
        case .wedding: return "\(time) since Wedding"
        case .work: return "\(time) since I joined"
        case .sobriety: return "\(time) Sober"
        case .quitting: return "\(time) since I quit"
        case .birthday: return "\(time) since Birthday"
        case .anniversary: return "\(time) since Anniversary"
        case .travel: return "\(time) since Travel"
        case .exam: return "\(time) since Exam"
        case .launch: return "\(time) since Launch"
        case .personal: return "\(time) since \(title)"
        }
    }
}
