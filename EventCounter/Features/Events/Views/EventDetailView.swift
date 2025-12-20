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

    var body: some View {
        Group {
            if event.isDeleted {
                ContentUnavailableView("Event Deleted", systemImage: "trash")
            } else {
                TimelineView(.periodic(from: .now, by: 1.0)) { context in
                    ScrollView {
                        VStack(spacing: 20) {
                            // Header Image or Icon
                            if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 250)
                                    .clipped()
                                    .cornerRadius(12)
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: event.colorHex) ?? .blue)
                                        .frame(width: 100, height: 100)
                                        .opacity(0.2)
                                    
                                    Image(systemName: event.category.icon)
                                        .font(.system(size: 40))
                                        .foregroundStyle(Color(hex: event.colorHex) ?? .blue)
                                }
                                .padding(.top, 20)
                            }
                            
                            Text(event.title)
                                .font(.largeTitle)
                                .bold()
                                .multilineTextAlignment(.center)
                            
                            // Countdown Logic
                            let components = CountdownService.calculateComponents(from: context.date, to: event.date)
                            
                            VStack(spacing: 10) {
                                Text(components.isPast ? "Event Passed" : "Time Remaining")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .textCase(.uppercase)
                                
                                HStack(spacing: 20) {
                                    if components.days > 0 {
                                        TimeUnitView(value: components.days, unit: "Days")
                                    } else {
                                        TimeUnitView(value: components.hours, unit: "Hours")
                                        TimeUnitView(value: components.minutes, unit: "Mins")
                                        TimeUnitView(value: components.seconds, unit: "Secs")
                                    }
                                }
                            }
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(16)
                            
                            // Metadata
                            VStack(alignment: .leading, spacing: 16) {
                                Label {
                                    Text(event.date.formatted(date: .long, time: .shortened))
                                } icon: {
                                    Image(systemName: "calendar")
                                }
                                
                                if event.recurrence != .once {
                                    Label {
                                        Text("Repeats \(event.recurrence.rawValue)")
                                    } icon: {
                                        Image(systemName: "repeat")
                                    }
                                }
                                
                                if let note = event.note, !note.isEmpty {
                                    Label {
                                        Text(note)
                                    } icon: {
                                        Image(systemName: "note.text")
                                    }
                                }
                                
                                Divider()
                                
                                Toggle("Pin to Top", isOn: Binding(
                                    get: { event.isPinned },
                                    set: { isOn in
                                        event.isPinned = isOn
                                        if isOn {
                                            if !LiveActivityService.shared.startLiveActivity(for: event) {
                                                event.isPinned = false // Revert if couldn't start
                                                showingLiveActivityAlert = true
                                            }
                                        } else {
                                            LiveActivityService.shared.endLiveActivity(for: event.id)
                                        }
                                        try? modelContext.save()
                                        WidgetCenter.shared.reloadAllTimelines()
                                    }
                                ))
                                
                                HStack {
                                    Text("Notify 15 mins before")
                                    Spacer()
                                    Toggle("", isOn: Binding(
                                        get: { event.notifyBefore != nil },
                                        set: { isOn in
                                            event.notifyBefore = isOn ? 15 : nil
                                            NotificationService.shared.scheduleNotification(for: event)
                                            try? modelContext.save()
                                            WidgetCenter.shared.reloadAllTimelines()
                                        }
                                    ))
                                }
                            }
                            .padding()
                            .background(Color(uiColor: .systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                            
                            Spacer()
                            
                            Button(role: .destructive) {
                                LiveActivityService.shared.endLiveActivity(for: event.id)
                                deleteEvent()
                            } label: {
                                Label("Delete Event", systemImage: "trash")
                            }
                            .padding(.bottom)
                            
                            if Activity<EventActivityAttributes>.activities.contains(where: { $0.attributes.eventID == event.id }) {
                                Button(role: .destructive) {
                                    LiveActivityService.shared.endLiveActivity(for: event.id)
                                } label: {
                                    Label("Stop Live Activity", systemImage: "stop.circle")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .padding(.horizontal)
                                .padding(.bottom)
                            } else {
                                Button {
                                    if !LiveActivityService.shared.startLiveActivity(for: event) {
                                        showingLiveActivityAlert = true
                                    }
                                } label: {
                                    Label("Track Live Activity", systemImage: "timer")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .padding(.horizontal)
                                .padding(.bottom)
                            }
                        }
                    }
                }
            }
        }
        
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
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddEventView(eventToEdit: event)
        }
    }
    
    
   
    
    private func deleteEvent() {
        modelContext.delete(event)
        try? modelContext.save() // Force write to disk before widget reloads
        WidgetCenter.shared.reloadAllTimelines()
        dismiss()
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
