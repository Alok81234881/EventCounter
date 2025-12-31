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
                    Text(context.state.eventDate, style: .timer)
                        .font(.title3)
                        .bold()
                        .monospacedDigit()
                        .foregroundStyle(Color(hex: context.state.colorHex) ?? .blue)
                        .padding(.trailing, 8)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.state.eventTitle)
                            .font(.headline)
                        
                        let total = context.state.eventDate.timeIntervalSince(context.state.creationDate)
                        let elapsed = Date().timeIntervalSince(context.state.creationDate)
                        let progress = total > 0 ? min(max(elapsed / total, 0), 1) : 1
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 4)
                                
                                Capsule()
                                    .fill(Color(hex: context.state.colorHex) ?? .blue)
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
                Text(context.state.eventDate, style: .timer)
                    .monospacedDigit()
                    .foregroundStyle(Color(hex: context.state.colorHex) ?? .blue)
            } minimal: {
                Image(systemName: context.state.categoryIcon)
                    .foregroundStyle(Color(hex: context.state.colorHex) ?? .blue)
            }
            .keylineTint(Color(hex: context.state.colorHex) ?? .blue)
        }
    }
}

struct EventLockScreenView: View {
    let context: ActivityViewContext<EventActivityAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            // Header Row
            Spacer(minLength: 20)
            HStack(spacing: 12) {
                // Category Icon
                ZStack {
                    Circle()
                        .fill(Color(white: 0.95))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: context.state.categoryIcon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color(red: 0.2, green: 0.25, blue: 0.35))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("UPCOMING")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(red: 0.45, green: 0.5, blue: 0.6))
                        .tracking(1)
                    
                    Text(context.state.eventTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.black)
                }
                
                Spacer()
                
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
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            // Countdown Row
            HStack(alignment: .lastTextBaseline, spacing: 12) {
                Text(context.state.eventDate, style: .timer)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.black)
                
                Spacer()
                
                Text("T-Minus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(red: 0.6, green: 0.65, blue: 0.75))
            }
            .padding(.horizontal, 20)
            
            // Progress Bar
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
            
            Spacer(minLength: 10)
        }
        .activityBackgroundTint(.white)
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
