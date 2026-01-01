import SwiftUI

struct HomeEventCardView: View {
    let event: Event
    
    private var isPastEvent: Bool {
        event.date <= .now
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // 1. Icon Circle
            ZStack {
               
                
                if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50) // Smaller than circle
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color(hex: event.colorHex)?.opacity(0.1) ?? .blue.opacity(0.1))
                        .frame(width: 50, height: 50)
                    Image(systemName: event.category.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(Color(hex: event.colorHex) ?? .blue)
                }
            }
            
            // 2. Middle Info
            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.adaptivePrimaryText)
                    .opacity(isPastEvent ? 0.5 : 1.0)
                
                HStack(spacing: 8) {
                    Text(event.date.formatted(.dateTime.month().day()))
                        .font(.system(size: 13))
                        .foregroundStyle(Color.adaptiveSecondaryText)
                    
                    // Category Tag
                    Text(event.category.rawValue.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color(hex: event.colorHex) ?? .blue)
                        .opacity(isPastEvent ? 0.5 : 1.0)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color(hex: event.colorHex)?.opacity(0.15) ?? .blue.opacity(0.15))
                                .opacity(isPastEvent ? 0.5 : 1.0)
                        )
                }
            }
            
            Spacer()
            
            // 3. Right Side - Countdown Circle
            if event.date > .now {
                TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
                    let components = CountdownService.calculateComponents(from: timeline.date, to: event.date, isCountUp: event.isCountUp)
                    let info = getUnitInfo(for: components, entryDate: timeline.date, targetDate: event.date)
                    
                    VStack(spacing: 0) {
                        Text(info.value)
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundStyle(Color(hex: event.colorHex) ?? .blue)
                        
                        Text(info.label)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.adaptiveSecondaryText)
                    }
                    .frame(width: 50, height: 50)
                    .background(Color.adaptiveSecondaryBackground)
                    .clipShape(Circle())
                }
            } else {
                // Past: Show only highest component (e.g., "1 year ago", "3 hrs ago")
                TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
                    let timeAgoText = getTimeAgoText(from: event.date, to: timeline.date)
                    Text(timeAgoText)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.adaptiveSecondaryText)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.adaptiveSecondaryBackground)
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        )
    }
    
    private func getUnitInfo(for components: CountdownComponents, entryDate: Date, targetDate: Date) -> (value: String, label: String) {
        let timeInterval = targetDate.timeIntervalSince(entryDate)
        
        if timeInterval <= 0 && !event.isCountUp {
            return ("0", "SEC")
        }
        
        let absInterval = abs(timeInterval)
        
        if absInterval >= 30 * 24 * 3600 {
            return ("\(components.months)", components.months == 1 ? "MONTH" : "MONTHS")
        } else if absInterval >= 24 * 3600 {
            let totalDays = (components.months * 30) + components.days
            return ("\(totalDays)", totalDays == 1 ? "DAY" : "DAYS")
        } else if absInterval >= 3600 {
            return ("\(components.hours)", components.hours == 1 ? "HR" : "HRS")
        } else if absInterval >= 60 {
            return ("\(components.minutes)", "MIN")
        } else {
            return ("\(components.seconds)", "SEC")
        }
    }
    
    private func getTimeAgoText(from pastDate: Date, to currentDate: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: pastDate, to: currentDate)
        
        // Check in order: year, month, day, hour, minute, second
        if let years = components.year, years > 0 {
            return "\(years) \(years == 1 ? "year" : "years") ago"
        } else if let months = components.month, months > 0 {
            return "\(months) \(months == 1 ? "month" : "months") ago"
        } else if let days = components.day, days > 0 {
            return "\(days) \(days == 1 ? "day" : "days") ago"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours) \(hours == 1 ? "hr" : "hrs") ago"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes) \(minutes == 1 ? "min" : "mins") ago"
        } else if let seconds = components.second, seconds > 0 {
            return "\(seconds) \(seconds == 1 ? "sec" : "secs") ago"
        } else {
            return "just now"
        }
    }
}
