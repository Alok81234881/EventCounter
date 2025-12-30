import Foundation

public struct CountdownComponents {
    public let days: Int
    public let hours: Int
    public let minutes: Int
    public let seconds: Int
    public let isPast: Bool
    public let isCountUp: Bool
    
    public var formattedTitle: String {
        if isPast && !isCountUp { return "Event Passed" }
        
        if days > 0 {
            return "\(days)d \(hours)h \(minutes)m"
        } else {
            return "\(hours)h \(minutes)m \(seconds)s"
        }
    }
    
    public var formattedTitleShort: String {
        if isPast && !isCountUp { return "Event Passed" }
        
        if days > 0 {
            return "\(days)d \(hours)h"
        } else {
            return "\(hours)h \(minutes)m"
        }
    }
    
    public func naturalDescription(category: EventCategory, title: String) -> String {
        if isPast && isCountUp {
            return category.milestoneDescription(for: title, time: formattedTitle)
        } else if isPast {
            return "Event Passed"
        } else {
            return "Time Remaining"
        }
    }
}

public struct CountdownService {
    public static func calculateComponents(from now: Date, to target: Date, isCountUp: Bool = false) -> CountdownComponents {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: now, to: target)
        
        let isPast = now > target
        
        return CountdownComponents(
            days: abs(components.day ?? 0),
            hours: abs(components.hour ?? 0),
            minutes: abs(components.minute ?? 0),
            seconds: abs(components.second ?? 0),
            isPast: isPast,
            isCountUp: isCountUp
        )
    }
}
