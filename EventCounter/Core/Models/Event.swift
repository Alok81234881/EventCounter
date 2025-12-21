import Foundation
import SwiftData

enum RecurrenceType: String, Codable, CaseIterable {
    case once = "Once"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}

@Model
final class Event {
    @Attribute(.unique) var id: UUID
    var title: String
    var date: Date
    var note: String?
    var category: EventCategory
    var colorHex: String
    var createdAt: Date
    var isPinned: Bool
    var notifyBefore: Int? // minutes
    
    // New Properties
    @Attribute(.externalStorage) var imageData: Data?
    var recurrence: RecurrenceType = RecurrenceType.once
    var isCountUp: Bool = false
    var widgetDisplayStyle: WidgetDisplayStyle = WidgetDisplayStyle.timer
    
    var progress: Double {
        let total = date.timeIntervalSince(createdAt)
        guard total > 0 else { return 1.0 }
        let elapsed = Date().timeIntervalSince(createdAt)
        return min(elapsed / total, 1.0)
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        note: String? = nil,
        category: EventCategory = .personal,
        colorHex: String = "#FF0000",
        isPinned: Bool = false,
        notifyBefore: Int? = nil,
        imageData: Data? = nil,
        recurrence: RecurrenceType = .once,
        isCountUp: Bool = false,
        widgetDisplayStyle: WidgetDisplayStyle = .timer
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.note = note
        self.category = category
        self.colorHex = colorHex
        self.createdAt = Date()
        self.isPinned = isPinned
        self.notifyBefore = notifyBefore
        self.imageData = imageData
        self.recurrence = recurrence
        self.isCountUp = isCountUp
        self.widgetDisplayStyle = widgetDisplayStyle
    }
}


enum WidgetDisplayStyle: String, Codable, CaseIterable {
    case timer = "Timer"
    case progress = "Progress"
}
