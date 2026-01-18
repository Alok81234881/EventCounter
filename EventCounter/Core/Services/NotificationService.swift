import UserNotifications
import UIKit
import Foundation
import Combine

class NotificationService: NSObject, ObservableObject {

    
    static let shared = NotificationService()
    
    @Published var isAuthorized = false
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
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
    
    func scheduleNotification(for event: Event, isReschedule: Bool = false) {
        // Double check permission before scheduling
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                print("[NotificationService] Not authorized. Status: \(settings.authorizationStatus.rawValue)")
                return
            }
            
            // Cancel existing notifications for this event
            self.cancelNotification(for: event)
            
            // 1. Process notificationOffsets
            if !event.notificationOffsets.isEmpty {
                print("[NotificationService] Scheduling \(event.notificationOffsets.count) notifications for '\(event.title)'")
                for minutes in event.notificationOffsets {
                    self.scheduleSpecificNotification(for: event, minutesBefore: minutes, isReschedule: isReschedule)
                }
            } 
            // 2. Fallback to legacy notifyBefore if offsets are empty
            else if let legacyMins = event.notifyBefore {
                print("[NotificationService] Scheduling legacy notification for '\(event.title)'")
                self.scheduleSpecificNotification(for: event, minutesBefore: legacyMins, isReschedule: isReschedule)
            } else {
                print("[NotificationService] No notification scheduled for '\(event.title)'")
            }
        }
    }
    
    private func scheduleSpecificNotification(for event: Event, minutesBefore: Int, isReschedule: Bool) {
        guard let triggerDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: event.date) else {
            print("[NotificationService] ERROR: Could not calculate trigger date for '\(event.title)'")
            return
        }
        
        let timeInterval = triggerDate.timeIntervalSinceNow
        
        // Skip past notifications unless testing, but logic below handles intervals
        if timeInterval <= 0 {
             print("[NotificationService] Trigger date (\(triggerDate)) is in the past. Skipping.")
             return
        }
        
        let trigger: UNNotificationTrigger
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate)
        trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "Event Reminder: \(event.title)"
        
        // Dynamic body
        let timeString: String
        let effectiveMinutes = minutesBefore
        
        if effectiveMinutes == 0 {
            timeString = "now"
        } else if effectiveMinutes < 60 {
            timeString = "\(effectiveMinutes) minutes"
        } else if effectiveMinutes < 1440 {
            let hours = effectiveMinutes / 60
            timeString = "\(hours) hour\(hours == 1 ? "" : "s")"
        } else {
            let days = effectiveMinutes / 1440
            timeString = "\(days) day\(days == 1 ? "" : "s")"
        }
        
        if effectiveMinutes == 0 {
            content.body = "Your \(event.title) event is happening now!"
        } else {
            content.body = "Your \(event.title) event is starting in \(timeString)!"
        }
        content.sound = .default
        content.userInfo = ["eventID": event.id.uuidString]
        
        // Unique Identifier: BaseID + Offset
        let identifier = "\(event.id.uuidString)_offset_\(minutesBefore)"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationService] ERROR: Failed to schedule offset \(minutesBefore) for '\(event.title)': \(error.localizedDescription)")
            } else {
                print("[NotificationService] SUCCESS: Scheduled notification for '\(event.title)' in \(timeString)")
            }
        }
    }
    
    func cancelNotification(for event: Event) {
        let baseID = event.id.uuidString
        
        // Cancel the main ID and any older staged IDs from the previous version
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let relatedIDs = requests.filter { $0.identifier.hasPrefix(baseID) }.map { $0.identifier }
            if !relatedIDs.isEmpty {
                print("[NotificationService] Cancelling \(relatedIDs.count) notification(s) for event '\(event.title)'")
            }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: relatedIDs)
        }
    }
    
    // Debug method to list all pending notifications
    func listPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("[NotificationService] Total pending notifications: \(requests.count)")
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    print("  - ID: \(request.identifier)")
                    print("    Title: \(request.content.title)")
                    print("    Body: \(request.content.body)")
                    print("    Trigger: \(trigger.dateComponents)")
                } else if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                    print("  - ID: \(request.identifier)")
                    print("    Title: \(request.content.title)")
                    print("    Body: \(request.content.body)")
                    print("    Trigger: Time interval \(trigger.timeInterval) seconds")
                }
            }
        }
    }
    
    // Reschedule notifications for all events (useful on app launch)
    func rescheduleNotificationsForEvents(_ events: [Event]) {
        print("[NotificationService] Rescheduling notifications for \(events.count) events")
        for event in events {
            if event.date > Date() && event.notifyBefore != nil {
                scheduleNotification(for: event, isReschedule: true)
            }
        }
    }
}

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let eventID = userInfo["eventID"] as? String,
           let url = URL(string: "eventcounter://event/\(eventID)") {
            // Open the URL using UIApplication
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
            }
        }
        
        completionHandler()
    }
    
    // Allow notifications to show even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
