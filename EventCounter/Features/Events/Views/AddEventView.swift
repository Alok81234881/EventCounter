import SwiftUI
import SwiftData
import WidgetKit
import UIKit
import PhotosUI
import EventKit

struct AddEventView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var eventToEdit: Event?
    
    @State private var title = ""
    @State private var date = Date()
    @State private var category: EventCategory = .personal
    @State private var selectedColor = Color.blue
    @State private var isPinned = false
    @State private var note = ""
    @State private var recurrence: RecurrenceType = .once
    @State private var notifyBefore: Int? = 15
    @State private var isCountUp = false
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    @State private var showingCalendarPicker = false
    @State private var calendarEvents: [EKEvent] = []
    @State private var isLoadingEvents = false
    
    @State private var showingImageCropper = false
    @State private var tempImage: UIImage?
    
    // Mapping Colors to Hex for simplicity.
    private let availableColors: [Color] = [.blue, .red, .green, .orange, .purple, .pink, .yellow]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button {
                        Task {
                            isLoadingEvents = true
                            calendarEvents = await CalendarService.shared.fetchUpcomingEvents()
                            isLoadingEvents = false
                            showingCalendarPicker = true
                        }
                    } label: {
                        HStack {
                            Label("Import from Calendar", systemImage: "calendar.badge.plus")
                            if isLoadingEvents {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                }
                
                Section("Event Details") {
                    TextField("Title", text: $title)
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    Picker("Repeats", selection: $recurrence) {
                        ForEach(RecurrenceType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section("Image") {
                    if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .listRowInsets(EdgeInsets())
                            .clipped()
                    }
                    
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label(selectedImageData == nil ? "Select Image" : "Change Image", systemImage: "photo")
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                tempImage = uiImage
                                showingImageCropper = true
                                selectedItem = nil // Reset picker
                            }
                        }
                    }
                }
                
                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(EventCategory.allCases, id: \.self) { cat in
                            Label(cat.displayName, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                }
                
                Section("Appearance") {
                    ColorPicker("Event Color", selection: $selectedColor)
                    Toggle("Pin to Top", isOn: $isPinned)
                    
                    Picker("Reminder", selection: $notifyBefore) {
                        Text("None").tag(nil as Int?)
                        Text("At time of event").tag(0 as Int?)
                        Text("5 minutes before").tag(5 as Int?)
                        Text("15 minutes before").tag(15 as Int?)
                        Text("30 minutes before").tag(30 as Int?)
                        Text("1 hour before").tag(60 as Int?)
                        Text("1 day before").tag(1440 as Int?)
                        Text("1 week before").tag(10080 as Int?)
                    }
                    
                    Toggle("Count up since this date", isOn: $isCountUp)
                }
                
                Section("Notes") {
                    TextField("Optional notes", text: $note, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle(eventToEdit == nil ? "New Event" : "Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEvent()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                if let event = eventToEdit {
                    title = event.title
                    date = event.date
                    category = event.category
                    selectedColor = Color(hex: event.colorHex) ?? .blue
                    isPinned = event.isPinned
                    note = event.note ?? ""
                    recurrence = event.recurrence
                    notifyBefore = event.notifyBefore
                    isCountUp = event.isCountUp
                    selectedImageData = event.imageData
                }
            }
            .sheet(isPresented: $showingCalendarPicker) {
                CalendarPickerView(events: calendarEvents) { ekEvent in
                    title = ekEvent.title
                    date = ekEvent.startDate
                    note = ekEvent.notes ?? ""
                    showingCalendarPicker = false
                }
            }
            .fullScreenCover(isPresented: $showingImageCropper) {
                if let image = tempImage {
                    ImageCropperView(image: image) { cropped in
                        if let data = cropped.jpegData(compressionQuality: 0.8) {
                            selectedImageData = data
                        }
                    }
                }
            }
        }
    }
    
    private func saveEvent() {
        // Convert Color to Hex String
        let hex = selectedColor.toHex() ?? "#0000FF"
        
        if let event = eventToEdit {
            event.title = title
            event.date = date
            event.category = category
            event.colorHex = hex
            event.isPinned = isPinned
            event.note = note.isEmpty ? nil : note
            event.recurrence = recurrence
            event.notifyBefore = notifyBefore
            event.isCountUp = isCountUp
            event.imageData = selectedImageData
            
            // Scheduling notification
            NotificationService.shared.scheduleNotification(for: event)
        } else {
            let newEvent = Event(
                title: title,
                date: date,
                note: note.isEmpty ? nil : note,
                category: category,
                colorHex: hex,
                isPinned: isPinned,
                notifyBefore: notifyBefore,
                imageData: selectedImageData,
                recurrence: recurrence,
                isCountUp: isCountUp
            )
            modelContext.insert(newEvent)
            NotificationService.shared.scheduleNotification(for: newEvent)
        }
        
        try? modelContext.save() // Force write to disk
        WidgetCenter.shared.reloadAllTimelines()
        dismiss()
    }
}

// Helper to get Hex from Color
extension Color {
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components else { return nil }
        
        let r = components[0]
        let g = components.count >= 3 ? components[1] : r
        let b = components.count >= 3 ? components[2] : r
        
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}

extension UIImage {
    func resized(to maxSize: CGSize) -> UIImage? {
        let aspectRatio = size.width / size.height
        var newSize = maxSize
        if aspectRatio > 1 {
            newSize.height = maxSize.width / aspectRatio
        } else {
            newSize.width = maxSize.height * aspectRatio
        }
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

struct CalendarPickerView: View {
    let events: [EKEvent]
    let onSelect: (EKEvent) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(events, id: \.eventIdentifier) { event in
                Button {
                    onSelect(event)
                } label: {
                    VStack(alignment: .leading) {
                        Text(event.title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(event.startDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Select Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .overlay {
                if events.isEmpty {
                    ContentUnavailableView("No Calendar Events", systemImage: "calendar.badge.exclamationmark", description: Text("Make sure you have granted calendar access or have upcoming events."))
                }
            }
        }
    }
}
