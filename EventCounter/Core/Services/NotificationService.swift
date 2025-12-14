import UserNotifications
import Foundation

class NotificationService: NSObject {
    static let shared = NotificationService()
    
    override private init() {
        super.init()
    }
    
    func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotification(for event: Event) {
        guard let notifyMinutes = event.notifyBefore else {
            // Cancel if disabled
            cancelNotification(for: event)
            return
        }
        
        // Calculate trigger date: Event Date - Minutes
        guard let triggerDate = Calendar.current.date(byAdding: .minute, value: -notifyMinutes, to: event.date),
              triggerDate > Date() else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Event Reminder"
        content.body = "\(event.title) is in \(notifyMinutes) minutes!"
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: event.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotification(for event: Event) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.id.uuidString])
    }
}
