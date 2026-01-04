import Foundation

public enum EventCategory: String, Codable, CaseIterable {
    case anniversary
    case birthday
    case calendar
    case exam
    case festival
    case holiday
    case launch
    case meeting
    case personal
    case travel
    case wedding
    case work
   
   
   
    
    
    public var icon: String {
        switch self {
        case .birthday: return "birthday.cake"
        case .travel: return "airplane"
        case .exam: return "book.closed"
        case .launch: return "fork.knife"
        case .personal: return "person"
        case .wedding: return "heart.fill"
        case .work: return "briefcase"
        case .meeting: return "person.2"
        case .holiday: return "sun.max"
        case .festival: return "party.popper"
        case .anniversary: return "star.fill"
        case .calendar: return "calendar"
        }
    }
    
    public var displayName: String {
        rawValue.capitalized
    }
    
    public func milestoneDescription(for title: String, time: String) -> String {
        switch self {
        case .wedding: return "\(time) since Wedding"
        case .work: return "\(time) since I joined"
        case .meeting: return "Meeting"
        case .holiday: return "Holiday"
        case .festival: return "Festival"
       // case .sobriety: return "\(time) Sober"
      //  case .quitting: return "\(time) since I quit"
        case .birthday: return "\(time) since Birthday"
        case .anniversary: return "\(time) since Anniversary"
        case .travel: return "\(time) since Travel"
        case .exam: return "\(time) since Exam"
        case .launch: return "\(time) since Launch"
        case .personal: return "\(time) since \(title)"
        case .calendar: return "Calender Event"
        }
    }
}
