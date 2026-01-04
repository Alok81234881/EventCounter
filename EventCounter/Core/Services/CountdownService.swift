import Foundation

public struct CountdownComponents {
    public let months: Int
    public let days: Int
    public let hours: Int
    public let minutes: Int
    public let seconds: Int
    public let isPast: Bool
    public let isCountUp: Bool
    
    public var formattedThreeComponents: String {
        if isPast && !isCountUp { return "Event Passed" }
        
        let totalDays = (months * 30) + days // Rough check for thresholds
        
        if totalDays >= 30 {
            // > 30 Days: Months, Days, Hours
            var parts: [String] = []
            if months > 0 { parts.append("\(months) month\(months == 1 ? "" : "s")") }
            if days > 0 { parts.append("\(days) day\(days == 1 ? "" : "s")") }
            if hours > 0 { parts.append("\(hours) hr\(hours == 1 ? "" : "s")") }
            return parts.joined(separator: ", ")
        } else if totalDays >= 1 {
            // < 30 Days: Days, Hours, Minutes
            var parts: [String] = []
            if days > 0 { parts.append("\(days) day\(days == 1 ? "" : "s")") }
            if hours > 0 { parts.append("\(hours) hour\(hours == 1 ? "" : "s")") }
            if minutes > 0 { parts.append("\(minutes) min\(minutes == 1 ? "" : "s")") }
            return parts.joined(separator: ", ")
        } else {
            // < 1 Day: Hours, Minutes, Seconds
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
    
    public var formattedTitle: String {
        if isPast && !isCountUp { return "Event Passed" }
        
        if days > 0 || months > 0 {
            return "\(months > 0 ? "\(months)m " : "")\(days)d \(hours)h \(minutes)m"
        } else {
            return "\(hours)h \(minutes)m \(seconds)s"
        }
    }
    
    public var formattedTitleShort: String {
        if isPast && !isCountUp { return "Event Passed" }
        
        if months > 0 {
            return "\(months)m \(days)d"
        } else if days > 0 {
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
    public var shareDisplayUnits: [(value: String, label: String)] {
        if months > 0 {
            return [
                ("\(months)", "MONTHS"),
                ("\(days)", "DAYS"),
                ("\(hours)", "HOURS")
            ]
        } else if days > 0 {
            return [
                ("\(days)", "DAYS"),
                (String(format: "%02d", hours), "HOURS"),
                (String(format: "%02d", minutes), "MINS")
            ]
        } else {
            return [
                (String(format: "%02d", hours), "HOURS"),
                (String(format: "%02d", minutes), "MINS"),
                (String(format: "%02d", seconds), "SECS")
            ]
        }
    }
}

public struct CountdownService {
    public static func calculateComponents(from now: Date, to target: Date, isCountUp: Bool = false) -> CountdownComponents {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day, .hour, .minute, .second], from: now, to: target)
        
        let isPast = now > target
        
        return CountdownComponents(
            months: abs(components.month ?? 0),
            days: abs(components.day ?? 0),
            hours: abs(components.hour ?? 0),
            minutes: abs(components.minute ?? 0),
            seconds: abs(components.second ?? 0),
            isPast: isPast,
            isCountUp: isCountUp
        )
    }
}
