import Foundation
import ActivityKit

class LiveActivityService {
    static let shared = LiveActivityService()
    
    private init() {}
    
    var activeActivity: Activity<EventActivityAttributes>? {
        Activity<EventActivityAttributes>.activities.first
    }
    
    func startSmartLiveActivity(for event: Event) {
        Task {
            if let current = activeActivity {
                if event.date < current.content.state.eventDate {
                    // New event is EARLIER - swap immediately
                    print("New event \(event.title) is earlier. Swapping activity...")
                    await endAllLiveActivities()
                    // Small delay to ensure system state updates
                    try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
                    startLiveActivity(for: event)
                } else {
                    // New event is LATER - keep current, but ensure new is "ready" (handled by isPinned in View)
                    print("Kept existing activity for '\(current.content.state.eventTitle)' as it starts sooner.")
                }
            } else {
                // Nothing running - start it
                startLiveActivity(for: event)
            }
        }
    }
    
    @discardableResult
    func startLiveActivity(for event: Event) -> Bool {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return false }
        
        // If an activity is already running, we don't start a new one here.
        // The UI will handle the warning/confirmation.
        if !Activity<EventActivityAttributes>.activities.isEmpty {
            print("[LiveActivity] Activity already running, skipping start.")
            return false
        }
        
        let attributes = EventActivityAttributes(eventID: event.id)
        let state = EventActivityAttributes.ContentState(
            eventTitle: event.title,
            eventDate: event.date,
            categoryIcon: event.category.icon,
            colorHex: event.colorHex,
            creationDate: event.createdAt
        )
        
        do {
            let _ = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
            print("Live Activity started for \(event.title)")
            return true
        } catch {
            print("Error requesting Live Activity: \(error.localizedDescription)")
            return false
        }
    }
    
    func endAllLiveActivities() async {
        for activity in Activity<EventActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        print("All Live Activities ended.")
    }
    
    func endLiveActivity(for eventID: UUID) {
        Task {
            for activity in Activity<EventActivityAttributes>.activities {
                if activity.attributes.eventID == eventID {
                    await activity.end(nil, dismissalPolicy: .immediate)
                }
            }
        }
    }
}
