import WidgetKit
import SwiftUI
import SwiftData
import UIKit

struct Provider: AppIntentTimelineProvider {
    @MainActor
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), event: EventDTO.preview, futureEventCount: 1)
    }

    @MainActor
    func snapshot(for configuration: SelectEventIntent, in context: Context) async -> SimpleEntry {
        let (event, count) = fetchNextEventAndCount(for: context.family, selectedID: configuration.event?.id)
        return SimpleEntry(date: Date(), event: event, futureEventCount: count)
    }

    @MainActor
    func timeline(for configuration: SelectEventIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let entryDate = Date()
        var entries: [SimpleEntry] = []
        
        // SMART ROTATION LOGIC
        if configuration.smartRotation {
            let (smartEvents, count) = fetchSmartEvents(for: context.family)
            
            if smartEvents.isEmpty {
                 entries.append(SimpleEntry(date: entryDate, event: nil, futureEventCount: count))
            } else {
                // Generate rotation: Every 15 minutes, switch event
                // Plan for next 4 hours
                let interval: TimeInterval = 15 * 60
                let totalDuration: TimeInterval = 4 * 60 * 60
                let steps = Int(totalDuration / interval)
                
                for i in 0..<steps {
                    let date = entryDate.addingTimeInterval(Double(i) * interval)
                    let eventIndex = i % smartEvents.count
                    let event = smartEvents[eventIndex]
                    entries.append(SimpleEntry(date: date, event: event, futureEventCount: count))
                }
            }
             return Timeline(entries: entries, policy: .atEnd)
        }
        
        // STANDARD LOGIC (Single Event)
        let (event, count) = fetchNextEventAndCount(for: context.family, selectedID: configuration.event?.id)
        
        if let targetDate = event?.date {
            let timeUntil = targetDate.timeIntervalSince(entryDate)
            let thirtyDays: TimeInterval = 30 * 24 * 3600
            let oneDay: TimeInterval = 24 * 3600
            
            if timeUntil > thirtyDays {
                // Mode 1: > 30 Days. Refresh every 1 hour is enough
                for i in 0..<12 {
                    let date = Calendar.current.date(byAdding: .hour, value: i, to: entryDate)!
                    entries.append(SimpleEntry(date: date, event: event, futureEventCount: count))
                }
            } else if timeUntil > oneDay {
                // Mode 2: < 30 Days. Refresh every minute for the next hour to show minutes correctly
                for i in 0..<60 {
                    let date = entryDate.addingTimeInterval(Double(i) * 60)
                    entries.append(SimpleEntry(date: date, event: event, futureEventCount: count))
                }
            } else {
                // Mode 3: < 1 Day. Refresh every minute to support static minute/hour text updates
                for i in 0..<60 {
                    let date = entryDate.addingTimeInterval(Double(i) * 60)
                    entries.append(SimpleEntry(date: date, event: event, futureEventCount: count))
                }
            }
            
            [thirtyDays, oneDay, 0].forEach { threshold in
                let reloadPoint = targetDate.addingTimeInterval(-threshold)
                if reloadPoint > entryDate && reloadPoint < entryDate.addingTimeInterval(3600 * 24) {
                    entries.append(SimpleEntry(date: reloadPoint, event: event, futureEventCount: count))
                }
            }
        } else {
            entries.append(SimpleEntry(date: entryDate, event: event, futureEventCount: count))
        }

        let uniqueEntries = Dictionary(grouping: entries, by: { Int($0.date.timeIntervalSince1970) })
            .compactMap { $0.value.first }
            .sorted(by: { $0.date < $1.date })
        
        return Timeline(entries: uniqueEntries, policy: .atEnd)
    }
    
    @MainActor
    private func fetchSmartEvents(for family: WidgetFamily) -> ([EventDTO], Int) {
        // Shared Model Container Logic
        let schema = Schema([Event.self])
        let modelConfiguration: ModelConfiguration
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.redonelabs.EventCounter") {
             let storeURL = appGroupURL.appendingPathComponent("EventCout.sqlite")
             modelConfiguration = ModelConfiguration(schema: schema, url: storeURL)
        } else {
             modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        }

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let context = container.mainContext
            let descriptor = FetchDescriptor<Event>(sortBy: [SortDescriptor(\.date, order: .forward)])
            let allEvents = try context.fetch(descriptor)
            let now = Date()
            
            // 1. Filter Future Events
            let futureEvents = allEvents.filter { $0.date > now }
            
            // 2. Score/Rank
            // Logic: Pinned first, then by date (soonest first)
            let smartSorted = futureEvents.sorted {
                if $0.isPinned != $1.isPinned {
                    return $0.isPinned // Pinned (true) comes before Unpinned (false)
                }
                return $0.date < $1.date // Soonest date first
            }
            
            // 3. Take Top 5
            let topEvents = Array(smartSorted.prefix(5))
            
            // 4. Convert to DTOs
            let dtos = topEvents.map { event -> EventDTO in
                var resizedImageData: Data? = nil
                if let originalData = event.imageData {
                    resizedImageData = resizeImage(data: originalData, targetSize: CGSize(width: 300, height: 300))
                }
                return EventDTO(
                    title: event.title,
                    date: event.date,
                    categoryIcon: event.category.icon,
                    colorHex: event.colorHex,
                    imageData: resizedImageData,
                    isCountUp: event.isCountUp,
                    categoryRaw: event.category.rawValue,
                    widgetDisplayStyle: event.widgetDisplayStyle.rawValue,
                    createdAt: event.createdAt,
                    id: event.id.uuidString
                )
            }
            
            return (dtos, futureEvents.count)
            
        } catch {
            print("Widget Smart Fetch Failed: \(error)")
            return ([], 0)
        }
    }
    
    @MainActor
    private func fetchNextEventAndCount(for family: WidgetFamily, selectedID: UUID? = nil) -> (EventDTO?, Int) {
        // Shared Model Container Logic
        let schema = Schema([Event.self])
        
        let modelConfiguration: ModelConfiguration
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.redonelabs.EventCounter") {
             let storeURL = appGroupURL.appendingPathComponent("EventCout.sqlite")
             modelConfiguration = ModelConfiguration(schema: schema, url: storeURL)
        } else {
             modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        }

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let context = container.mainContext
            let descriptor = FetchDescriptor<Event>(
                sortBy: [SortDescriptor(\.date, order: .forward)]
            )
            let allEvents = try context.fetch(descriptor)
            let now = Date()
            
            let futureEvents = allEvents.filter { $0.date > now }
            let pastEvents = allEvents.filter { $0.date <= now }
            
            var selectedEvent: Event?
            
            // Priority 1: User selected event via Widget Configuration
            if let selectedID = selectedID {
                selectedEvent = allEvents.first(where: { $0.id == selectedID })
            }
            
            // Priority 2: Fallback logic if no event selected or selected event not found
            if selectedEvent == nil {
                switch family {
                case .systemSmall:
                    selectedEvent = pastEvents.sorted(by: { $0.date > $1.date }).first
                default:
                    selectedEvent = futureEvents.sorted(by: { $0.date < $1.date }).first
                }
            }
            
            if let event = selectedEvent {
                var resizedImageData: Data? = nil
                if let originalData = event.imageData {
                    resizedImageData = resizeImage(data: originalData, targetSize: CGSize(width: 300, height: 300))
                }
                
                let dto = EventDTO(
                    title: event.title,
                    date: event.date,
                    categoryIcon: event.category.icon,
                    colorHex: event.colorHex,
                    imageData: resizedImageData,
                    isCountUp: event.isCountUp,
                    categoryRaw: event.category.rawValue,
                    widgetDisplayStyle: event.widgetDisplayStyle.rawValue,
                    createdAt: event.createdAt,
                    id: event.id.uuidString
                )
                
                let relevantCount = (family == .systemSmall) ? pastEvents.count : futureEvents.count
                return (dto, relevantCount)
            }
            return (nil, 0)
        } catch {
            print("Widget Fetch Failed: \(error)")
            return (nil, 0)
        }
    }

    private func resizeImage(data: Data, targetSize: CGSize) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: image.size.width * heightRatio, height: image.size.height * heightRatio)
        } else {
            newSize = CGSize(width: image.size.width * widthRatio,  height: image.size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage?.jpegData(compressionQuality: 0.7)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let event: EventDTO?
    let futureEventCount: Int // This can be used in the view to show how many future events exist
}

// Mock extension for preview
extension EventDTO {
    static var preview: EventDTO {
        EventDTO(title: "Mahima", date: Date().addingTimeInterval(4800), categoryIcon: "cake", colorHex: "#FF0000", imageData: nil, isCountUp: false, categoryRaw: "anniversary", widgetDisplayStyle: "Timer", createdAt: Date().addingTimeInterval(-3600), id: UUID().uuidString)
    }
}
