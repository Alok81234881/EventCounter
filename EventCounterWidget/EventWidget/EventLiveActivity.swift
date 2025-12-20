import ActivityKit
import WidgetKit
import SwiftUI

public struct EventActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var eventTitle: String
        public var eventDate: Date
        
        public init(eventTitle: String, eventDate: Date) {
            self.eventTitle = eventTitle
            self.eventDate = eventDate
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
            // Lock Screen/Banner UI
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(context.state.eventTitle)
                            .font(.headline)
                        Text(context.state.eventDate, style: .timer)
                            .font(.title2)
                            .bold()
                            .monospacedDigit()
                    }
                    Spacer()
                }
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.8))
           // .activitySystemActionTint(Color.blue)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Text("⏳")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.eventDate, style: .timer)
                        .monospacedDigit()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.eventTitle)
                        .font(.headline)
                        .padding(.top, 5)
                }
            } compactLeading: {
                Text("⏳")
            } compactTrailing: {
                Text(context.state.eventDate, style: .timer)
                    .monospacedDigit()
            } minimal: {
                Text("⏳")
            }
            .keylineTint(Color.blue)
        }
    }
}
