import ActivityKit
import WidgetKit
import SwiftUI

public struct EventActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var eventTitle: String
        public var eventDate: Date
        public var categoryIcon: String
        public var colorHex: String
        public var creationDate: Date
        
        public init(eventTitle: String, eventDate: Date, categoryIcon: String, colorHex: String, creationDate: Date) {
            self.eventTitle = eventTitle
            self.eventDate = eventDate
            self.categoryIcon = categoryIcon
            self.colorHex = colorHex
            self.creationDate = creationDate
        }
    }

    public var eventID: UUID
    
    public init(eventID: UUID) {
        self.eventID = eventID
    }
}

struct EventLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: EventActivityAttributes.self) { context in
            EventLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.state.categoryIcon)
                        .font(.title2)
                        .foregroundStyle(Color(hex: context.state.colorHex) ?? .blue)
                        .padding(.leading, 8)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if Date() >= context.state.eventDate {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                            Text("Done")
                                .font(.title3)
                                .bold()
                        }
                        .foregroundStyle(Color.green)
                        .padding(.trailing, 8)
                    } else {
                        Text(context.state.eventDate, style: .timer)
                            .font(.title3)
                            .bold()
                            .monospacedDigit()
                            .foregroundStyle(Color(hex: context.state.colorHex) ?? .blue)
                            .padding(.trailing, 8)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.state.eventTitle)
                            .font(.headline)
                        
                        let isCompleted = Date() >= context.state.eventDate
                        let total = context.state.eventDate.timeIntervalSince(context.state.creationDate)
                        let elapsed = Date().timeIntervalSince(context.state.creationDate)
                        let progress = total > 0 ? min(max(elapsed / total, 0), 1) : 1
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 4)
                                
                                Capsule()
                                    .fill(isCompleted ? Color.green : (Color(hex: context.state.colorHex) ?? .blue))
                                    .frame(width: geo.size.width * CGFloat(progress), height: 4)
                            }
                        }
                        .frame(height: 4)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            } compactLeading: {
                Image(systemName: context.state.categoryIcon)
                    .foregroundStyle(Color(hex: context.state.colorHex) ?? .blue)
            } compactTrailing: {
                if Date() >= context.state.eventDate {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.green)
                } else {
                    Text(context.state.eventDate, style: .timer)
                        .monospacedDigit()
                        .foregroundStyle(Color(hex: context.state.colorHex) ?? .blue)
                }
            } minimal: {
                if Date() >= context.state.eventDate {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.green)
                } else {
                    Image(systemName: context.state.categoryIcon)
                        .foregroundStyle(Color(hex: context.state.colorHex) ?? .blue)
                }
            }
            .keylineTint(Color(hex: context.state.colorHex) ?? .blue)
        }
    }
}

struct EventLockScreenView: View {
    let context: ActivityViewContext<EventActivityAttributes>
    
    private var isCompleted: Bool {
        Date() >= context.state.eventDate
    }
    
    private var timeSinceCompletion: TimeInterval {
        max(0, Date().timeIntervalSince(context.state.eventDate))
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header Row
            Spacer(minLength: 20)
            HStack(spacing: 12) {
                // Category Icon
                ZStack {
                    Circle()
                        .fill(Color(uiColor: .secondarySystemBackground))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: context.state.categoryIcon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.primary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(isCompleted ? "COMPLETED" : "UPCOMING")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.secondary)
                        .tracking(1)
                    
                    Text(context.state.eventTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.primary)
                }
                
                Spacer()
                
                // Status Badge
                if isCompleted {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                        Text("DONE")
                            .font(.system(size: 12, weight: .black))
                    }
                    .foregroundStyle(Color.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.1))
                    .clipShape(Capsule())
                } else {
                    // LIVE Badge
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(hex: context.state.colorHex) ?? .blue)
                            .frame(width: 8, height: 8)
                        
                        Text("LIVE")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(Color(hex: context.state.colorHex) ?? .blue)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background((Color(hex: context.state.colorHex) ?? .blue).opacity(0.1))
                    .clipShape(Capsule())
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            // Countdown/Completion Row
            HStack(alignment: .lastTextBaseline, spacing: 12) {
                if isCompleted {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Event Completed!")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.green)
                        
                        Text(formatTimeSinceCompletion(timeSinceCompletion))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.secondary)
                    }
                } else {
                    Text(context.state.eventDate, style: .timer)
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Color.primary)
                }
                
                Spacer()
                
                if !isCompleted {
                    Text("T-Minus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.secondary)
                }
            }
            .padding(.horizontal, 20)
            
            // Progress Bar
            if !isCompleted {
                VStack(spacing: 8) {
                    // Using ProgressView with timerInterval for live-animating progress bar
                    ProgressView(
                        timerInterval: context.state.creationDate...context.state.eventDate,
                        countsDown: false
                    )
                    .tint(Color(hex: context.state.colorHex) ?? .blue)
                    .scaleEffect(x: 1, y: 2, anchor: .center) // Make it slightly thicker
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            } else {
                // Completed progress bar (100%)
                VStack(spacing: 8) {
                    ProgressView(value: 1.0)
                        .tint(Color.green)
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            
           // Spacer(minLength: 10)
        }
        .activityBackgroundTint(Color(uiColor: .systemBackground))
    }
    
    private func formatTimeSinceCompletion(_ interval: TimeInterval) -> String {
        let minutes = Int(interval / 60)
        let hours = Int(interval / 3600)
        
        if hours > 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else if minutes > 0 {
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else {
            return "Just completed"
        }
    }
}

#Preview("Upcoming (Days)", as: .content, using: EventActivityAttributes(eventID: UUID())) {
    EventLiveActivity()
} contentStates: {
    EventActivityAttributes.ContentState(
        eventTitle: "SpaceX Launch",
        eventDate: Date().addingTimeInterval(3600 * 24 * 12 + 3600 * 5 + 180),
        categoryIcon: "rocket.fill",
        colorHex: "#5B56E1",
        creationDate: Date().addingTimeInterval(-3600 * 24)
    )
}

#Preview("Soon (Seconds)", as: .content, using: EventActivityAttributes(eventID: UUID())) {
    EventLiveActivity()
} contentStates: {
    EventActivityAttributes.ContentState(
        eventTitle: "Falcon Landing",
        eventDate: Date().addingTimeInterval(3600 * 2 + 180),
        categoryIcon: "airplane",
        colorHex: "#FF9500",
        creationDate: Date().addingTimeInterval(-3600 * 4)
    )
}
