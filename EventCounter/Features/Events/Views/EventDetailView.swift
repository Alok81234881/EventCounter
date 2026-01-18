import SwiftUI
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
                            GeometryReader { geometry in
                                let minY = geometry.frame(in: .global).minY
                                let size = geometry.size
                                let height = size.height + (minY > 0 ? minY : 0)
                                let yOffset = minY > 0 ? -minY : 0
                                
                                Group {
                                    if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                    } else {
                                        Rectangle()
                                            .fill(Color(hex: event.colorHex) ?? .blue)
                                    }
                                }
                                .frame(width: size.width, height: height)
                                .clipped()
                                .offset(y: yOffset)
                            }
                            .frame(height: 300)
                            
                            .overlay(alignment: .bottomLeading) {
                                // Title Overlay
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(event.title)
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundStyle(.white)
                                    
                                    Text(event.category.displayName)
                                        .font(.system(size: 16))
                                        .foregroundStyle(.white.opacity(0.8))
                                }
                                .padding(.horizontal, 24)
                                .padding(.bottom, 100)
                                .allowsHitTesting(false) //Decorative overlay
                            }
                            
                            // Countdown Card (Overlapping)
                            VStack(spacing: 16) {
                                let timeUntil = event.date.timeIntervalSince(context.date)
                                let thirtyDays: TimeInterval = 30 * 24 * 3600
                                let oneDay: TimeInterval = 24 * 3600
                                let themeColor = Color(hex: event.colorHex) ?? .purple
                                
                                HStack(spacing: 0) {
                                    if event.isCountUp {
                                        // Count-up: always show Mo, d, h (or whatever makes sense)
                                        // But following the "3 components" rule:
                                        if components.months > 0 {
                                            CountdownUnitView(value: components.months, unit: "mo", color: themeColor, showPadding: false)
                                            SeparatorView(color: themeColor)
                                            CountdownUnitView(value: components.days, unit: "d", color: themeColor)
                                            SeparatorView(color: themeColor)
                                            CountdownUnitView(value: components.hours, unit: "h", color: themeColor)
                                        } else if components.days > 0 {
                                            CountdownUnitView(value: components.days, unit: "d", color: themeColor, showPadding: false)
                                            SeparatorView(color: themeColor)
                                            CountdownUnitView(value: components.hours, unit: "h", color: themeColor)
                                            SeparatorView(color: themeColor)
                                            CountdownUnitView(value: components.minutes, unit: "m", color: themeColor)
                                        } else {
                                            CountdownUnitView(value: components.hours, unit: "h", color: themeColor, showPadding: false)
                                            SeparatorView(color: themeColor)
                                            CountdownUnitView(value: components.minutes, unit: "m", color: themeColor)
                                            SeparatorView(color: themeColor)
                                            CountdownUnitView(value: components.seconds, unit: "s", color: themeColor)
                                        }
                                    } else if timeUntil > thirtyDays {
                                        // Mode 1: Months, Days, Hours
                                        CountdownUnitView(value: components.months, unit: "mo", color: themeColor, showPadding: false)
                                        SeparatorView(color: themeColor)
                                        CountdownUnitView(value: components.days, unit: "d", color: themeColor)
                                        SeparatorView(color: themeColor)
                                        CountdownUnitView(value: components.hours, unit: "h", color: themeColor)
                                    } else if timeUntil > oneDay {
                                        // Mode 2: Days, Hours, Minutes
                                        CountdownUnitView(value: components.days, unit: "d", color: themeColor, showPadding: false)
                                        SeparatorView(color: themeColor)
                                        CountdownUnitView(value: components.hours, unit: "h", color: themeColor)
                                        SeparatorView(color: themeColor)
                                        CountdownUnitView(value: components.minutes, unit: "m", color: themeColor)
                                    } else if timeUntil > 0 {
                                        // Mode 3: Hours, Minutes, Seconds
                                        CountdownUnitView(value: components.hours, unit: "h", color: themeColor, showPadding: false)
                                        SeparatorView(color: themeColor)
                                        CountdownUnitView(value: components.minutes, unit: "m", color: themeColor)
                                        SeparatorView(color: themeColor)
                                        CountdownUnitView(value: components.seconds, unit: "s", color: themeColor)
                                    } else {
                                        Text("Event Completed")
                                            .font(.system(size: 28, weight: .bold, design: .rounded))
                                            .foregroundStyle(themeColor)
                                    }
                                }
                                
                                // Progress Bar Section
                                HStack {
                                    Text("NOW")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(Color.adaptiveSecondaryText)
                                    
                                    Spacer()
                                    
                                    Text(event.date.formatted(.dateTime.month(.abbreviated).day()))
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(Color.adaptiveSecondaryText)
                                }
                                
                                // Gradient Progress Bar
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.adaptiveSecondaryText.opacity(0.2))
                                        .frame(height: 8)
                                    
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(hex: "#800080") ?? .purple,
                                                    .pink
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: max(8, UIScreen.main.bounds.width * 0.85 * event.progress), height: 8)
                                }
                                
                                Text("\(Int(event.progress * 100))% of the wait is over!")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.adaptiveSecondaryText)
                            }
                            .padding(24)
                            .background(Color.adaptiveSecondaryBackground)
                            .cornerRadius(24)
                            .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
                            .padding(.horizontal, 20)
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
                                                Text(reminderText(event))
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
                HStack(spacing: 8) {
                    Button {
                        showingSharePreview = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(Color.adaptivePrimaryText)
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
        if let mins = minutes {
            event.notificationOffsets = [mins]
        } else {
            event.notificationOffsets = []
        }
        
        try? modelContext.save()
        
        // Reschedule notification
        NotificationService.shared.scheduleNotification(for: event)
        
        // Cloud Sync
        CloudKitService.shared.syncEvent(event)
    }
    
    private func reminderText(_ event: Event) -> String {
        if !event.notificationOffsets.isEmpty {
            let sorted = event.notificationOffsets.sorted()
            if sorted.count == 1 {
                return formatMinutes(sorted.first!)
            } else {
                return "\(sorted.count) Reminders"
            }
        }
        return formatMinutes(event.notifyBefore)
    }
    
    private func formatMinutes(_ minutes: Int?) -> String {
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
