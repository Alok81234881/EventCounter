import UserNotifications
import Foundation
import Combine

class NotificationService: NSObject, ObservableObject {

    
    static let shared = NotificationService()
    
    @Published var isAuthorized = false
    
    override private init() {
        super.init()
        checkPermissionStatus()
    }
    
    func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotification(for event: Event) {
        // Double check permission before scheduling
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            
            guard let notifyMinutes = event.notifyBefore else {
                // Cancel if disabled
                self.cancelNotification(for: event)
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
    }
    
    func cancelNotification(for event: Event) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.id.uuidString])
    }
}
