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
    
    func scheduleNotification(for event: Event) {
        // Double check permission before scheduling
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                print("[NotificationService] Not authorized. Status: \(settings.authorizationStatus.rawValue)")
                return
            }
            
            // Cancel existing notifications for this event
            self.cancelNotification(for: event)
            
            if let notifyMinutes = event.notifyBefore {
                print("[NotificationService] Scheduling notification for '\(event.title)' \(notifyMinutes) minutes before event at \(event.date)")
                self.scheduleSpecificNotification(for: event, minutesBefore: notifyMinutes)
            } else {
                print("[NotificationService] No notification scheduled for '\(event.title)' - notifyBefore is nil")
            }
        }
    }
    
    private func scheduleSpecificNotification(for event: Event, minutesBefore: Int) {
        guard let triggerDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: event.date) else {
            print("[NotificationService] ERROR: Could not calculate trigger date for '\(event.title)'")
            return
        }
        
        guard triggerDate > Date() else {
            print("[NotificationService] WARNING: Trigger date (\(triggerDate)) is in the past for '\(event.title)'. Event date: \(event.date), Minutes before: \(minutesBefore)")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "\(event.category) Reminder"
        
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
        
        content.userInfo = ["eventID": event.id.uuidString]
        
        let identifier = event.id.uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationService] ERROR: Failed to schedule notification for '\(event.title)': \(error.localizedDescription)")
            } else {
                print("[NotificationService] SUCCESS: Notification scheduled for '\(event.title)' at \(triggerDate) (event at \(event.date))")
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
                scheduleNotification(for: event)
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
