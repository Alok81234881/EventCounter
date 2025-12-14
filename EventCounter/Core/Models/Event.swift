import Foundation
import SwiftData

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
    
    init(id: UUID = UUID(), title: String, date: Date, note: String? = nil, category: EventCategory = .personal, colorHex: String = "#FF0000", isPinned: Bool = false, notifyBefore: Int? = nil) {
        self.id = id
        self.title = title
        self.date = date
        self.note = note
        self.category = category
        self.colorHex = colorHex
        self.createdAt = Date()
        self.isPinned = isPinned
        self.notifyBefore = notifyBefore
    }
}
