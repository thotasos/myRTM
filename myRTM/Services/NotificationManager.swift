import Foundation
import UserNotifications
import SwiftData

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }

    func scheduleNotification(for task: TaskItem) {
        guard let dueDate = task.dueDate else { return }

        // Schedule 15 minutes before
        let triggerDate = dueDate.addingTimeInterval(-15 * 60)

        // Don't schedule if trigger date is in the past
        guard triggerDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Task Due Soon"
        content.body = task.title
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    func cancelNotification(for task: TaskItem) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }

    func updateNotification(for task: TaskItem) {
        cancelNotification(for: task)
        if task.dueDate != nil && !task.isCompleted {
            scheduleNotification(for: task)
        }
    }
}
