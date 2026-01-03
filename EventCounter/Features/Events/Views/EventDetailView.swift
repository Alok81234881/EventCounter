import SwiftUI
import SwiftData
import WidgetKit
import ActivityKit

struct EventDetailView: View {
    @Bindable var event: Event
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditSheet = false
    @State private var showingLiveActivityAlert = false
    @State private var showingDeleteAlert = false
    @State private var showingSharePreview = false
    @State private var showingReminderPicker = false

    var body: some View {
        VStack {
            // Root Background: Theme color for top (to prevent flicker), adaptive background for bottom
//            VStack(spacing: 0) {
//                (Color(hex: event.colorHex) ?? .blue)
//                    .frame(height: 300)
//                Color.adaptiveGroupedBackground
//            }
//            .ignoresSafeArea()
            
            if event.isDeleted {
                ContentUnavailableView("Event Deleted", systemImage: "trash")
            } else {
                TimelineView(.periodic(from: .now, by: 1.0)) { context in
                    let components = CountdownService.calculateComponents(from: context.date, to: event.date, isCountUp: event.isCountUp)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Hero Image Section
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
                            .frame(height: 300)
                            .clipped()
                            
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
                                
                                HStack(spacing: 0) {
                                    if event.isCountUp {
                                        // Count-up: always show Mo, d, h (or whatever makes sense)
                                        // But following the "3 components" rule:
                                        if components.months > 0 {
                                            CountdownUnitView(value: components.months, unit: "mo", showPadding: false)
                                            SeparatorView()
                                            CountdownUnitView(value: components.days, unit: "d")
                                            SeparatorView()
                                            CountdownUnitView(value: components.hours, unit: "h")
                                        } else if components.days > 0 {
                                            CountdownUnitView(value: components.days, unit: "d", showPadding: false)
                                            SeparatorView()
                                            CountdownUnitView(value: components.hours, unit: "h")
                                            SeparatorView()
                                            CountdownUnitView(value: components.minutes, unit: "m")
                                        } else {
                                            CountdownUnitView(value: components.hours, unit: "h", showPadding: false)
                                            SeparatorView()
                                            CountdownUnitView(value: components.minutes, unit: "m")
                                            SeparatorView()
                                            CountdownUnitView(value: components.seconds, unit: "s")
                                        }
                                    } else if timeUntil > thirtyDays {
                                        // Mode 1: Months, Days, Hours
                                        CountdownUnitView(value: components.months, unit: "mo", showPadding: false)
                                        SeparatorView()
                                        CountdownUnitView(value: components.days, unit: "d")
                                        SeparatorView()
                                        CountdownUnitView(value: components.hours, unit: "h")
                                    } else if timeUntil > oneDay {
                                        // Mode 2: Days, Hours, Minutes
                                        CountdownUnitView(value: components.days, unit: "d", showPadding: false)
                                        SeparatorView()
                                        CountdownUnitView(value: components.hours, unit: "h")
                                        SeparatorView()
                                        CountdownUnitView(value: components.minutes, unit: "m")
                                    } else if timeUntil > 0 {
                                        // Mode 3: Hours, Minutes, Seconds
                                        CountdownUnitView(value: components.hours, unit: "h", showPadding: false)
                                        SeparatorView()
                                        CountdownUnitView(value: components.minutes, unit: "m")
                                        SeparatorView()
                                        CountdownUnitView(value: components.seconds, unit: "s")
                                    } else {
                                        Text("Event Completed")
                                            .font(.system(size: 28, weight: .bold, design: .rounded))
                                            .foregroundStyle(Color(hex: "#800080") ?? Color.purple)
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
                                                Text(reminderText(event.notifyBefore))
                                                    .font(.system(size: 13))
                                                    .foregroundStyle(Color.adaptiveSecondaryText)
                                            }
                                            
                                            Spacer()
                                            
//                                            Image(systemName: "chevron.right")
//                                                .font(.system(size: 14, weight: .semibold))
//                                                .foregroundStyle(.gray.opacity(0.5))
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
                                                event.isPinned = isOn
                                                if isOn {
                                                    if !LiveActivityService.shared.startLiveActivity(for: event) {
                                                        event.isPinned = false
                                                        showingLiveActivityAlert = true
                                                    }
                                                } else {
                                                    LiveActivityService.shared.endLiveActivity(for: event.id)
                                                }
                                                try? modelContext.save()
                                                WidgetCenter.shared.reloadAllTimelines()
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
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.red)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 40)
                            .padding(.bottom, 40)
                        }
                    }
                    .ignoresSafeArea(edges: .top)
                }
            }
        }
        .overlay(alignment: .top) {
            // Top Navigation Buttons
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.adaptivePrimaryText)
                        .frame(width: 42, height: 42)
                        .background(Color.adaptiveTertiaryBackground)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                .contentShape(Circle())
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button {
                        showingSharePreview = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.adaptivePrimaryText)
                            .frame(width: 42, height: 42)
                            .background(Color.adaptiveTertiaryBackground)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .contentShape(Circle())
                    
                    Button {
                        showingEditSheet = true
                    } label: {
                        Text("Edit")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.adaptivePrimaryText)
                            .frame(width: 50, height: 42)
                            .background(Color.adaptiveTertiaryBackground)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .contentShape(Capsule())
                }
            }
            .padding()
//            .padding(.top, 20)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .alert("Activity Already Running", isPresented: $showingLiveActivityAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Add") {
                event.isPinned = true
                LiveActivityService.shared.startSmartLiveActivity(for: event)
                
                try? modelContext.save()
                WidgetCenter.shared.reloadAllTimelines()
            }
        } message: {
            if let active = LiveActivityService.shared.activeActivity {
                let activeTitle = active.content.state.eventTitle
                let activeDate = active.content.state.eventDate
                
                if event.date < activeDate {
                    Text("The event '\(event.title)' starts sooner than '\(activeTitle)'. If you add it, we'll switch to tracking this event immediately to keep your countdown most relevant.")
                } else {
                    Text("You're already tracking '\(activeTitle)', which happens earlier. If you add this, we'll continue showing the earliest event first. Once it's done, you can track this one!")
                }
            } else {
                Text("One Live Activity is already started. If you add this, the upcoming event's activity will show first. When it's done, the next one can start.")
            }
        }
        .alert("Delete Event?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteEvent()
            }
        } message: {
            Text("Are you sure you want to delete this event?\nThis action cannot be undone.")
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
        .fullScreenCover(isPresented: $showingSharePreview) {
            if let components = try? CountdownService.calculateComponents(from: .now, to: event.date, isCountUp: event.isCountUp) {
                SharePreviewView(event: event, components: components)
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
        LiveActivityService.shared.endLiveActivity(for: event.id)
        modelContext.delete(event)
        try? modelContext.save() // Force write to disk before widget reloads
        WidgetCenter.shared.reloadAllTimelines()
        dismiss()
    }
    
    private func updateReminder(_ minutes: Int?) {
        event.notifyBefore = minutes
        try? modelContext.save()
        
        // Reschedule notification
        NotificationService.shared.scheduleNotification(for: event)
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
    var showPadding: Bool = true
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(showPadding ? String(format: "%02d", value) : "\(value)")
                .font(.system(size: 36, weight: .bold))
            Text(unit)
                .font(.system(size: 20, weight: .semibold))
        }
        .foregroundStyle(Color(hex: "#800080") ?? Color.purple)
    }
}

struct SeparatorView: View {
    var body: some View {
        Text(" : ")
            .font(.system(size: 36, weight: .bold))
            .foregroundStyle(Color(hex: "#800080") ?? Color.purple)
    }
}
