import Foundation

struct CountdownComponents {
    let days: Int
    let hours: Int
    let minutes: Int
    let seconds: Int
    let isPast: Bool
    
    var formattedTitle: String {
        if isPast { return "Event Passed" }
        if days > 0 {
            return "\(days) \(days == 1 ? "Day" : "Days")"
        } else {
            return "\(hours)h \(minutes)m \(seconds)s"
        }
    }
}

struct CountdownService {
    static func calculateComponents(from now: Date, to target: Date) -> CountdownComponents {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: now, to: target)
        
        let isPast = now > target
        
        return CountdownComponents(
            days: abs(components.day ?? 0),
            hours: abs(components.hour ?? 0),
            minutes: abs(components.minute ?? 0),
            seconds: abs(components.second ?? 0),
            isPast: isPast
        )
    }
}
