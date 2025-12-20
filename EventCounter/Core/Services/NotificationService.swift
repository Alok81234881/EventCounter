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
            
            // Cancel existing notifications for this event
            self.cancelNotification(for: event)
            
            if let notifyMinutes = event.notifyBefore {
                self.scheduleSpecificNotification(for: event, minutesBefore: notifyMinutes)
            }
        }
    }
    
    private func scheduleSpecificNotification(for event: Event, minutesBefore: Int) {
        guard let triggerDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: event.date),
              triggerDate > Date() else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Event Reminder"
        
        // Dynamic label based on minutes
        let label: String
        if minutesBefore == 0 {
            label = "Now"
        } else if minutesBefore < 60 {
            label = "\(minutesBefore) minutes"
        } else if minutesBefore < 1440 {
            label = "\(minutesBefore / 60) hour\(minutesBefore / 60 == 1 ? "" : "s")"
        } else if minutesBefore < 10080 {
            label = "\(minutesBefore / 1440) day\(minutesBefore / 1440 == 1 ? "" : "s")"
        } else {
            label = "\(minutesBefore / 10080) week\(minutesBefore / 10080 == 1 ? "" : "s")"
        }
        
        content.body = minutesBefore == 0 ? "\(event.title) is happening now!" : "\(event.title) is in \(label)!"
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = event.id.uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotification(for event: Event) {
        let baseID = event.id.uuidString
        
        // Cancel the main ID and any older staged IDs from the previous version
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let relatedIDs = requests.filter { $0.identifier.hasPrefix(baseID) }.map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: relatedIDs)
        }
    }
}
