import Foundation
import CloudKit
import SwiftUI
import SwiftData
import Combine

class CloudKitService: ObservableObject {
    static let shared = CloudKitService()
    
    // CloudKit Container & Database
    private let container = CKContainer(identifier: "iCloud.com.redonelabs.EventCounter")
    private var database: CKDatabase {
        return container.privateCloudDatabase
    }
    
    private let zone = CKRecordZone(zoneName: "EventsZone")
    
    // Sync State
    @Published var isSyncing = false
    @Published var lastSyncDate: Date? {
        didSet {
            UserDefaults.standard.set(lastSyncDate, forKey: "lastCloudSyncDate")
        }
    }
    @Published var iCloudAvailable = false
    
    private init() {
        self.lastSyncDate = UserDefaults.standard.object(forKey: "lastCloudSyncDate") as? Date
        
        Task {
            await checkAccountStatus()
            await createZoneIfNeeded()
        }
    }
    
    // MARK: - Helpers
    private var isSyncEnabled: Bool {
        return UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")
    }
    
    // MARK: - Account Status
    func checkAccountStatus() async {
        do {
            let status = try await container.accountStatus()
            await MainActor.run {
                self.iCloudAvailable = (status == .available)
            }
        } catch {
             await MainActor.run { self.iCloudAvailable = false }
        }
    }
    
    private func createZoneIfNeeded() async {
        guard iCloudAvailable else { return }
        
        do {
            try await database.save(zone)
            print("CloudKit: Custom zone 'EventsZone' created/verified.")
        } catch {
             // 13/2007 = Zone already exists, simple ignore (or handle gracefully)
             // But usually save() works as upsert or fails if unchanged.
             print("CloudKit: Zone creation check: \(error.localizedDescription)")
        }
    }
    
    // MARK: - CRUD Operations
    
    /// Saves or Updates an Event in iCloud
    func syncEvent(_ event: Event) {
        guard isSyncEnabled, iCloudAvailable else { return }
        
        Task { @MainActor in
            isSyncing = true
            
            // USE CUSTOM ZONE ID
            let recordID = CKRecord.ID(recordName: event.id.uuidString, zoneID: zone.zoneID)
            let record = CKRecord(recordType: "Event", recordID: recordID)
            
            // Map Properties
            record["title"] = event.title
            record["date"] = event.date
            record["note"] = event.note
            record["category"] = event.category.rawValue
            record["colorHex"] = event.colorHex
            record["createdAt"] = event.createdAt
            record["isPinned"] = event.isPinned
            record["notifyBefore"] = event.notifyBefore
            
            record["recurrence"] = event.recurrence.rawValue
            record["isCountUp"] = event.isCountUp
            record["widgetDisplayStyle"] = event.widgetDisplayStyle.rawValue
            record["location"] = event.location
            
            // Handle Image Asset
            if let imageData = event.imageData {
                if let asset = createAsset(from: imageData) {
                    record["imageData"] = asset
                }
            }
            
            do {
                try await database.save(record)
                print("CloudKit: Successfully synced event \(event.title)")
                lastSyncDate = Date()
            } catch {
                print("CloudKit: Sync failed for \(event.title): \(error.localizedDescription)")
            }
            
            isSyncing = false
        }
    }
    
    /// Deletes an Event from iCloud
    func deleteEvent(_ event: Event) {
        guard isSyncEnabled, iCloudAvailable else { return }
        
        Task {
            do {
                // USE CUSTOM ZONE ID
                let recordID = CKRecord.ID(recordName: event.id.uuidString, zoneID: zone.zoneID)
                try await database.deleteRecord(withID: recordID)
                print("CloudKit: Deleted event \(event.title)")
            } catch {
                print("CloudKit: Delete failed: \(error.localizedDescription)")
            }
        }
    }
    
    /// Restores all events from iCloud to Local SwiftData
    func restoreEvents(context: ModelContext) async {
        guard isSyncEnabled else { return }
        
        // Double check account status before running
        await checkAccountStatus()
        guard iCloudAvailable else {
            print("CloudKit: Account not available. Aborting restore.")
            return
        }
        
        await MainActor.run { isSyncing = true }
        
        // USE CUSTOM ZONE ID
        let config = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
        config.previousServerChangeToken = nil // Start from beginning for restore
        
        let operation = CKFetchRecordZoneChangesOperation(recordZoneIDs: [zone.zoneID], configurationsByRecordZoneID: [zone.zoneID: config])
        operation.qualityOfService = .userInitiated
        
        // Use a continuation to bridge the callback-based operation to async/await
        await withCheckedContinuation { continuation in
            var fetchedDTOs: [CloudEventDTO] = []
            
            operation.recordWasChangedBlock = { recordID, result in
                switch result {
                case .success(let record):
                    // Extract data immediately while asset file exists
                    let dto = CloudEventDTO(from: record)
                    fetchedDTOs.append(dto)
                case .failure(let error):
                    print("CloudKit: Failed to fetch record \(recordID): \(error)")
                }
            }
            
            operation.fetchRecordZoneChangesCompletionBlock = { error in
                if let error = error {
                    print("CloudKit: Zone fetch failed: \(error)")
                } else {
                    print("CloudKit: Zone fetch success. Processing \(fetchedDTOs.count) records.")
                    Task { @MainActor in
                        for dto in fetchedDTOs {
                            self.importDTO(dto, context: context)
                        }
                        
                        do {
                            try context.save()
                            print("CloudKit: Synced \(fetchedDTOs.count) events from cloud.")
                        } catch {
                            print("CloudKit: Failed to save restored events: \(error.localizedDescription)")
                        }
                        
                        self.lastSyncDate = Date()
                        self.isSyncing = false
                    }
                }
                continuation.resume()
            }
            
            database.add(operation)
        }
    }
    
    // MARK: - Import Logic
    
    @MainActor
    private func importDTO(_ dto: CloudEventDTO, context: ModelContext) {
        let idUUID = UUID(uuidString: dto.id) ?? UUID()
        
        // Check if exists
        let descriptor = FetchDescriptor<Event>(predicate: #Predicate { $0.id == idUUID })
        if let existing = try? context.fetch(descriptor).first {
             // Update existing
             updateEvent(existing, from: dto)
        } else {
             // Create new
             let event = Event(id: idUUID, title: dto.title, date: dto.date)
             updateEvent(event, from: dto)
             context.insert(event)
        }
    }
    
    @MainActor
    private func updateEvent(_ event: Event, from dto: CloudEventDTO) {
        event.title = dto.title
        event.date = dto.date
        event.note = dto.note
        
        if let cat = EventCategory(rawValue: dto.categoryRaw) {
            event.category = cat
        }
        event.colorHex = dto.colorHex
        event.createdAt = dto.createdAt
        event.isPinned = dto.isPinned
        event.notifyBefore = dto.notifyBefore
        
        if let rec = RecurrenceType(rawValue: dto.recurrenceRaw) {
            event.recurrence = rec
        }
        event.isCountUp = dto.isCountUp
        if let style = WidgetDisplayStyle(rawValue: dto.widgetDisplayStyleRaw) {
            event.widgetDisplayStyle = style
        }
        event.location = dto.location
        
        // Image Data (Directly from DTO)
        if let data = dto.imageData {
            event.imageData = data
        }
    }



// MARK: - DTO for Safe Asset Extraction
private struct CloudEventDTO {
    let id: String
    let title: String
    let date: Date
    let note: String?
    let categoryRaw: String
    let colorHex: String
    let createdAt: Date
    let isPinned: Bool
    let notifyBefore: Int?
    let recurrenceRaw: String
    let isCountUp: Bool
    let widgetDisplayStyleRaw: String
    let location: String?
    let imageData: Data?
    
    init(from record: CKRecord) {
        self.id = record.recordID.recordName
        self.title = record["title"] as? String ?? "Untitled"
        self.date = record["date"] as? Date ?? Date()
        self.note = record["note"] as? String
        self.categoryRaw = record["category"] as? String ?? "Personal"
        self.colorHex = record["colorHex"] as? String ?? "#FF0000"
        self.createdAt = record["createdAt"] as? Date ?? Date()
        self.isPinned = record["isPinned"] as? Bool ?? false
        self.notifyBefore = record["notifyBefore"] as? Int
        
        self.recurrenceRaw = record["recurrence"] as? String ?? "Once"
        self.isCountUp = record["isCountUp"] as? Bool ?? false
        self.widgetDisplayStyleRaw = record["widgetDisplayStyle"] as? String ?? "Timer"
        self.location = record["location"] as? String
        
        // Extract Asset Data Immediately
        if let asset = record["imageData"] as? CKAsset,
           let fileURL = asset.fileURL {
            do {
                self.imageData = try Data(contentsOf: fileURL)
            } catch {
                print("CloudKit: Failed to read asset data for \(self.title): \(error)")
                self.imageData = nil
            }
        } else {
            self.imageData = nil
        }
    }
}

    
    // MARK: - Bulk Sync
    
    /// Triggers a full sync cycle: Restore then Push All
    func performFullSync(context: ModelContext) async {
        guard isSyncEnabled else { return }
        
        // 1. Restore (Fetch down)
        await restoreEvents(context: context)
        
        // 2. Push All (Upload up)
        await syncAllEvents(context: context)
    }
    
    /// Pushes all local events to CloudKit
    func syncAllEvents(context: ModelContext) async {
        guard isSyncEnabled, iCloudAvailable else { return }
        
        await MainActor.run { isSyncing = true }
        
        do {
            let descriptor = FetchDescriptor<Event>()
            let allEvents = try await MainActor.run { try context.fetch(descriptor) }
            
            print("CloudKit: Starting bulk sync for \(allEvents.count) events...")
            
            for event in allEvents {
                // Reuse existing sync logic
                syncEvent(event)
                try? await Task.sleep(nanoseconds: 50_000_000) // 0.05s
            }
            
        } catch {
            print("CloudKit: Failed to fetch local events for bulk sync: \(error)")
        }
        
        await MainActor.run { isSyncing = false }
    }
    
    /// Deletes ALL data in the Private Database (for Account Deletion)
    func deleteCloudData() {
        guard isSyncEnabled, iCloudAvailable else { return }
        
        // Delete the entire zone
        Task {
            do {
                try await database.deleteRecordZone(withID: zone.zoneID)
                print("CloudKit: Deleted EventsZone.")
            } catch {
                print("CloudKit: Failed to delete zone: \(error)")
            }
        }
    }
    
    // MARK: - Asset Helper
private func createAsset(from data: Data) -> CKAsset? {
    let tempDir = FileManager.default.temporaryDirectory
    let fileURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
    
    do {
        try data.write(to: fileURL)
        return CKAsset(fileURL: fileURL)
    } catch {
        print("CloudKit: Failed to write temp image: \(error)")
        return nil
    }
    
}
}
