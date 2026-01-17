import SwiftUI
import CloudKit
import SwiftData
import WidgetKit
import ActivityKit

struct EventDetailView: View {
    @Bindable var event: Event
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingSharePreview = false
    @State private var showingReminderPicker = false
    @State private var showingPermissionAlert = false
    
    // Sharing State
    @State private var showingCloudSharing = false
    @State private var currentShare: CKShare?
    @State private var sharingContainer: CKContainer?

    var body: some View {
        VStack {
            
            if event.isDeleted {
                ContentUnavailableView("Event Deleted", systemImage: "trash")
            } else {
                TimelineView(.periodic(from: .now, by: 1.0)) { context in
                    let components = CountdownService.calculateComponents(from: context.date, to: event.date, isCountUp: event.isCountUp)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Hero Image Section
                            EventHeroImage(event: event)
                            
                            // Countdown Card (Overlapping)
                            EventCountdownCard(event: event, date: context.date)
                                .offset(y: -50)
                            
                            // Details Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Details")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(Color.adaptivePrimaryText)
                                
                                VStack(spacing: 20) {
                                    // Date Row
                                    DetailRow(
                                        icon: "calendar",
                                        iconColor: Color(hex: "#800080") ?? Color.purple,
                                        title: "DATE",
                                        value: event.date.formatted(date: .long, time: .omitted),
                                        trailingSubtitle: event.date.formatted(.dateTime.weekday(.wide))
                                    )
                                    
                                    // Time Row
                                    DetailRow(
                                        icon: "clock.fill",
                                        iconColor: Color.purple,
                                        title: "TIME",
                                        value: event.date.formatted(date: .omitted, time: .shortened),
                                        subtitle: nil
                                    )
                                    
                                    // Location Row
                                    if let location = event.location, !location.isEmpty {
                                        DetailRow(
                                            icon: "mappin",
                                            iconColor: Color.red,
                                            title: "LOCATION",
                                            value: location,
                                            subtitle: nil
                                        )
                                    }
                                    
                                    // Notes Row
                                    if let note = event.note, !note.isEmpty {
                                        DetailRow(
                                            icon: "doc.text.fill",
                                            iconColor: Color.gray,
                                            title: "NOTES",
                                            value: note,
                                            isBoldValue: false
                                        )
                                    }
                                }
                                .padding(20)
                                .background(Color.adaptiveSecondaryBackground)
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, -20)
                            
                            // Settings Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Settings")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(Color.adaptivePrimaryText)
                                
                                VStack(spacing: 16) {
                                    // Notify Before
//                                    Button {
//                                        showingReminderPicker = true
//                                    } label: {
                                        HStack(spacing: 16) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.cyan.opacity(0.15))
                                                    .frame(width: 40, height: 40)
                                                Image(systemName: "bell.fill")
                                                    .font(.system(size: 18))
                                                    .foregroundStyle(Color.cyan)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Notify Before")
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundStyle(Color.adaptivePrimaryText)
                                                Text(reminderText(event.notifyBefore))
                                                    .font(.system(size: 13))
                                                    .foregroundStyle(Color.adaptiveSecondaryText)
                                            }
                                            
                                            Spacer()

                                        }
                                 //   }
                                    
                                    // Live Activity Toggle
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.purple.opacity(0.15))
                                                .frame(width: 40, height: 40)
                                            Image(systemName: "chart.bar.fill")
                                                .font(.system(size: 18))
                                                .foregroundStyle(Color.purple)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Live Activity")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundStyle(Color.adaptivePrimaryText)
                                            Text("Show on Lock Screen")
                                                .font(.system(size: 13))
                                                .foregroundStyle(Color.adaptiveSecondaryText)
                                        }
                                        
                                        Spacer()
                                        
                                        Toggle("", isOn: Binding(
                                            get: { event.isPinned },
                                            set: { isOn in
                                                if isOn {
                                                    // 1. Unpin all other events in the DB to keep state consistent
                                                    // (We can't use a Predicate with != ID easily in SwiftData sometimes due to UUID issues, 
                                                    // so we fetch all pinned and filter, or just fetch all pinned)
                                                    // Simpler: Fetch all events where isPinned == true
                                                    // Note: Complex predicates can crash previews/etc, keep it simple.
                                                    let descriptor = FetchDescriptor<Event>(predicate: #Predicate { $0.isPinned })
                                                    if let pinnedEvents = try? modelContext.fetch(descriptor) {
                                                        for pinnedEvent in pinnedEvents {
                                                            pinnedEvent.isPinned = false
                                                        }
                                                    }
                                                    
                                                    // 2. Pin this one and start activity
                                                    event.isPinned = true
                                                    if !LiveActivityService.shared.startLiveActivity(for: event) {
                                                        // Failed likely due to permissions
                                                        event.isPinned = false
                                                        showingPermissionAlert = true
                                                    }
                                                } else {
                                                    event.isPinned = false
                                                    LiveActivityService.shared.endLiveActivity(for: event.id)
                                                }
                                                try? modelContext.save()
                                                if event.isPinned { WidgetCenter.shared.reloadAllTimelines() }
                                                CloudKitService.shared.syncEvent(event)
                                            }
                                        ))
                                        .tint(Color(hex: "#800080"))
                                    }
                                }
                                .padding(20)
                                .background(Color.adaptiveSecondaryBackground)
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 32)
                            
                            // Delete Button
                            Button(role: .destructive) {
                                showingDeleteAlert = true
                            } label: {
                                Text("Delete Event")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(
                                        Color.red.opacity(0.08)
                                    )
                                    .clipShape(Capsule())
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 40)

                        }
                    }
                    .ignoresSafeArea(edges: .top)
                    .onAppear {
                        // Double-check: If UI says pinned, is it REALLY running?
                        // If the system killed it, we should reflect that.
                        // Or if we switched to another event on a different device (iCloud) - though Live Activity is local.
                        // Mostly: If we came back from another screen and something changed.
                        if event.isPinned {
                            let isRunning = LiveActivityService.shared.activeActivity?.attributes.eventID == event.id
                            if !isRunning {
                                event.isPinned = false
                                // We don't save context here to avoid view-cycle save loops unless necessary, 
                                // but for correct UI state it's safer to just update the memory object.
                            }
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.adaptivePrimaryText)
                }
            }
            
//            ToolbarItem(placement: .principal) {
//                Text("Event Details")
//                    .font(.system(size: 18, weight: .semibold))
//                    .foregroundStyle(Color.adaptivePrimaryText)
//            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 20) {
                    
                    // Share Live Link
                    Button {
                        // Check if already shared
                        Task {
                            if let share = await CloudKitService.shared.fetchShare(for: event) {
                                self.currentShare = share
                                self.sharingContainer = CKContainer(identifier: "iCloud.com.redonelabs.EventCounter")
                                self.showingCloudSharing = true
                            } else {
                                // Create new share
                                try? await createShare()
                            }
                        }
                    } label: {
                        Image(systemName: "link.icloud")
                            .foregroundStyle(Color.adaptivePrimaryText)
                            .font(.system(size: 16, weight: .semibold))

                    }
                    
                    Button {
                        showingSharePreview = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(Color.adaptivePrimaryText)
                            .font(.system(size: 16, weight: .semibold))

                    }
                    
                    Button {
                        showingEditSheet = true
                    } label: {
                        Text("Edit")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.adaptivePrimaryText)
                    }
                }
                .padding(.leading, 5)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)

        .alert("Delete Event", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                deleteEvent()
            }
        } message: {
            Text("Are you sure you want to delete this event? This action cannot be undone.")
        }
        .sheet(isPresented: $showingEditSheet) {
            AddEventView(eventToEdit: event)
        }
        .confirmationDialog("Change Reminder", isPresented: $showingReminderPicker, titleVisibility: .visible) {
            Button("None") { updateReminder(nil) }
            Button("At time of event") { updateReminder(0) }
            Button("5 minutes before") { updateReminder(5) }
            Button("15 minutes before") { updateReminder(15) }
            Button("30 minutes before") { updateReminder(30) }
            Button("1 hour before") { updateReminder(60) }
            Button("1 day before") { updateReminder(1440) }
            Button("1 week before") { updateReminder(10080) }
            Button("Cancel", role: .cancel) { }
        }
        .alert("Enable Live Activities", isPresented: $showingPermissionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please enable Live Activities in Settings to track this event on your Lock Screen.")
        }
        .sheet(isPresented: $showingSharePreview) {
            if let components = try? CountdownService.calculateComponents(from: .now, to: event.date, isCountUp: event.isCountUp) {
                SharePreviewView(event: event, components: components)
                    .presentationDetents([.fraction(0.86)])
            }
        }
        .sheet(isPresented: $showingCloudSharing) {
            if let share = currentShare, let container = sharingContainer {
                CloudSharingView(share: share, container: container)
            }
        }

    }
    
    
    @MainActor
    private func renderShareImage() -> UIImage? {
        let components = CountdownService.calculateComponents(from: .now, to: event.date)
        let renderer = ImageRenderer(content: SocialShareCardView(event: event, components: components))
        renderer.scale = 3.0 // High quality
        return renderer.uiImage
    }
    
    
   
    
    private func deleteEvent() {
        NotificationService.shared.cancelNotification(for: event)
        LiveActivityService.shared.endLiveActivity(for: event.id)
        modelContext.delete(event)
        try? modelContext.save() // Force write to disk before widget reloads
        
        // Cloud Delete
        CloudKitService.shared.deleteEvent(event)
        
        WidgetCenter.shared.reloadAllTimelines()
        dismiss()
    }
    
    private func updateReminder(_ minutes: Int?) {
        event.notifyBefore = minutes
        try? modelContext.save()
        
        // Reschedule notification
        // Reschedule notification
        NotificationService.shared.scheduleNotification(for: event)
        
        // Cloud Sync
        CloudKitService.shared.syncEvent(event)
    }
    
    private func reminderText(_ minutes: Int?) -> String {
        guard let mins = minutes else { return "No reminder" }
        switch mins {
        case 0: return "At time of event"
        case 5: return "5 minutes before"
        case 15: return "15 minutes before"
        case 30: return "30 minutes before"
        case 60: return "1 hour before"
        case 1440: return "1 day before"
        case 10080: return "1 week before"
        default: return "\(mins) mins before"
        }
    }
    
    // MARK: - Sharing Logic
    private func createShare() async {
        do {
            let result = try await CloudKitService.shared.createShare(for: event)
            self.currentShare = result.0
            self.sharingContainer = result.1
            self.showingCloudSharing = true
        } catch {
            print("Failed to share: \(error)")
        }
    }
}


struct TimeUnitView: View {
    let value: Int
    let unit: String
    
    var body: some View {
        VStack {
            Text("\(value)")
                .font(.title2)
                .bold()
                .monospacedDigit()
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 50)
    }
}

struct DetailRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    var subtitle: String? = nil
    var trailingSubtitle: String? = nil
    var isBoldValue: Bool = true
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.gray)
                
                Text(value)
                    .font(.system(size: 16, weight: isBoldValue ? .semibold : .regular))
                    .foregroundStyle(Color.adaptivePrimaryText)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.adaptiveSecondaryText)
                }
            }
            
            Spacer()
            
            if let trailingSubtitle = trailingSubtitle {
                Text(trailingSubtitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.adaptiveSecondaryText)
            }
        }
    }
}

struct CountdownUnitView: View {
    let value: Int
    let unit: String
    var color: Color = Color(hex: "#800080") ?? .purple
    var showPadding: Bool = true
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(showPadding ? String(format: "%02d", value) : "\(value)")
                .font(.system(size: 36, weight: .bold))
            Text(unit)
                .font(.system(size: 20, weight: .semibold))
        }
        .foregroundStyle(color)
    }
}

struct SeparatorView: View {
    var color: Color = Color(hex: "#800080") ?? .purple
    
    var body: some View {
        Text(" : ")
            .font(.system(size: 36, weight: .bold))
            .foregroundStyle(color)
    }
}
