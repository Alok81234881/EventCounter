import Foundation

struct CountdownComponents {
    let days: Int
    let hours: Int
    let minutes: Int
    let seconds: Int
    let isPast: Bool
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
