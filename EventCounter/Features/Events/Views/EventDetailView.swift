import SwiftUI
import SwiftData
import WidgetKit

struct EventDetailView: View {
    @Bindable var event: Event
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

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
                                deleteEvent()
                            } label: {
                                Label("Delete Event", systemImage: "trash")
                            }
                            .padding(.bottom)
                        }
                    }
                }
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
    
    @State private var showingEditSheet = false
    
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
