import SwiftUI
import SwiftData
import WidgetKit
import UIKit
import PhotosUI
import EventKit
import MapKit

struct AddEventView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query var existingEvents: [Event]
    
    var eventToEdit: Event?
    
    // MARK: - State Properties
    @State private var title = ""
    @State private var date = Date()
    @State private var location = ""
    @State private var note = ""
    @State private var category: EventCategory = .personal
    @State private var selectedColor = Color(hex: "#800080") ?? .purple // Default per mockup (Travel/Orange)
    
    // New: Multiple notification offsets
    @State private var selectedNotificationOffsets: Set<Int> = [15] // Default 15 min
    
    @State private var showDuplicateAlert = false
    
    // Image Handling
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showingImageCropper = false
    @State private var tempImage: UIImage?
    
    // Calendar Import
    @State private var showingCalendarPicker = false
    @State private var showingTimePicker = false
    @State private var showingDatePicker = false
    @State private var isLoadingEvents = false
    
    // Location Suggestions
    @StateObject private var locationSearchService = LocationSearchService()
    @State private var showLocationSuggestions = false
    @FocusState private var isLocationFocused: Bool
    
    // Mockup Colors
    private let availableColors: [Color] = [
        Color(hex: "#F5A623") ?? .orange, // Orange
        Color(hex: "#E04F97") ?? .pink,   // Pink
        Color(hex: "#800080") ?? .purple, // Purple
        Color(hex: "#2F80ED") ?? .blue,   // Blue
        Color(hex: "#27AE60") ?? .green,  // Green
        Color(hex: "#FFB7A5") ?? Color(red: 1.0, green: 0.72, blue: 0.65)  // Dark
    ]
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // 1. Cover Photo Area
                        coverPhotoSection
                        
                        // 2. Event Name
                        VStack(alignment: .leading, spacing: 8) {
                            labelView("EVENT NAME")
                            HStack(spacing: 12) {
                                Image(systemName: "pencil")
                                    .foregroundStyle(Color.adaptiveSecondaryText)
                                TextField("", text: $title, prompt: Text("e.g. Cabo Trip, Mom's Bday").foregroundColor(.adaptiveSecondaryText))
                                    .foregroundStyle(Color.adaptivePrimaryText)
                                    .submitLabel(.done)
                            }
                            .padding()
                            .background(Color.adaptiveSecondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        // 3. Date & Time
                        HStack(spacing: 16) {
                            // Date
                            VStack(alignment: .leading, spacing: 8) {
                                labelView("DATE")
                                Button {
                                    showingDatePicker = true
                                } label: {
                                    HStack {
                                        Text(date.formatted(.dateTime.month().day().year()))
                                            .foregroundStyle(Color.adaptivePrimaryText)
                                        Spacer()
                                        Image(systemName: "calendar")
                                            .foregroundStyle(Color.adaptiveSecondaryText)
                                    }
                                    .padding()
                                    .background(Color.adaptiveSecondaryBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .frame(height: 56)
                                }
                            }
                            
                            // Time
                            VStack(alignment: .leading, spacing: 8) {
                                labelView("TIME")
                                Button {
                                    showingTimePicker = true
                                } label: {
                                    HStack {
                                        Text(date.formatted(.dateTime.hour().minute()))
                                            .foregroundStyle(Color.adaptivePrimaryText)
                                        Spacer()
                                        Image(systemName: "clock")
                                            .foregroundStyle(Color.adaptiveSecondaryText)
                                    }
                                    .padding()
                                    .background(Color.adaptiveSecondaryBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .frame(height: 56)
                                }
                            }
                        }
                        
                        // 4. Location
                        VStack(alignment: .leading, spacing: 8) {
                            labelView("LOCATION")
                            VStack(spacing: 0) {
                                VStack(spacing: 0) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "mappin.and.ellipse")
                                            .foregroundStyle(Color.adaptiveSecondaryText)
                                        TextField("", text: $location, prompt: Text("e.g. Central Park, NY").foregroundColor(.adaptiveSecondaryText))
                                            .foregroundStyle(Color.adaptivePrimaryText)
                                            .submitLabel(.done)
                                            .focused($isLocationFocused)
                                            .onChange(of: location) { newValue in
                                                locationSearchService.searchQuery = newValue
                                                withAnimation {
                                                    showLocationSuggestions = !newValue.isEmpty && isLocationFocused
                                                }
                                            }
                                    }
                                    .padding()
                                    .background(Color.clear)
                                    .zIndex(1)
                                    if showLocationSuggestions && !locationSearchService.completions.isEmpty {
                                        ScrollView(.vertical, showsIndicators: true) {
                                            VStack(alignment: .leading, spacing: 0) {
                                                ForEach(locationSearchService.completions, id: \.self) { completion in
                                                    Button {
                                                        location = "\(completion.title), \(completion.subtitle)"
                                                        withAnimation {
                                                            showLocationSuggestions = false
                                                            isLocationFocused = false
                                                        }
                                                    } label: {
                                                        HStack(spacing: 12) {
                                                            Image(systemName: "mappin.circle.fill")
                                                                .foregroundStyle(.gray.opacity(0.5))
                                                            VStack(alignment: .leading, spacing: 2) {
                                                                Text(completion.title)
                                                                    .font(.system(size: 15, weight: .medium))
                                                                    .foregroundStyle(Color.adaptivePrimaryText)
                                                                Text(completion.subtitle)
                                                                    .font(.system(size: 12))
                                                                    .foregroundStyle(Color.adaptiveSecondaryText)
                                                            }
                                                            Spacer()
                                                        }
                                                        .padding(.vertical, 12)
                                                        .padding(.horizontal)
                                                    }
                                                    if completion != locationSearchService.completions.last {
                                                        Divider()
                                                            .padding(.leading, 44)
                                                    }
                                                }
                                            }
                                            .padding(.vertical, 4)
                                        }
                                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.adaptiveSecondaryBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.adaptiveSecondaryText.opacity(0.15), lineWidth: 1)
                                        )
                                        .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
                                        .frame(maxHeight: 250)
                                        .padding(.horizontal, 4)
                                        .zIndex(10)
                                    }
                                }
                            }
                            .background(Color.adaptiveSecondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .onChange(of: isLocationFocused) { focused in
                            withAnimation {
                                showLocationSuggestions = focused && !location.isEmpty
                            }
                        }
                        
                        // 5. Notes
                        VStack(alignment: .leading, spacing: 8) {
                            labelView("NOTES")
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "text.alignleft")
                                    .foregroundStyle(Color.adaptiveSecondaryText)
                                    .padding(.top, 4)
                                TextField("", text: $note, prompt: Text("Add details, #hashtags, links...").foregroundColor(.adaptiveSecondaryText), axis: .vertical)
                                    .foregroundStyle(Color.adaptivePrimaryText)
                                    .submitLabel(.done)
                                    .lineLimit(3...6)
                            }
                            .padding()
                            .background(Color.adaptiveSecondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        // 7. Event Type
                        VStack(alignment: .leading, spacing: 12) {
                            labelView("EVENT TYPE")
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(sortedCategories, id: \.self) { cat in
                                        Button {
                                            withAnimation { category = cat }
                                        } label: {
                                            HStack(spacing: 8) {
                                                Image(systemName: cat.icon)
                                                Text(cat.displayName)
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .background(category == cat ? Color.adaptiveSecondaryBackground : Color.adaptiveSecondaryBackground)
                                            .foregroundStyle(category == cat ? selectedColor : Color.adaptiveSecondaryText)
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(category == cat ? selectedColor : Color.clear, lineWidth: 2)
                                            )
                                            // Add shadow only if not selected for depth, or keep flat
                                            .shadow(color: .black.opacity(0.05), radius: 2)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        
                        // 8. Theme Color
                        VStack(alignment: .leading, spacing: 12) {
                            labelView("THEME COLOR")
                            HStack(spacing: 16) {
                                ForEach(availableColors, id: \.self) { color in
                                    Button {
                                        selectedColor = color
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .fill(color)
                                                .frame(width: 44, height: 44)
                                            
                                            if selectedColor == color {
                                                Circle()
                                                    .stroke(Color.adaptiveSecondaryBackground, lineWidth: 3)
                                                    .frame(width: 40, height: 40)
                                            }
                                        }
                                        // Outer ring for selection
                                        .overlay(
                                            Circle()
                                                .stroke(color.opacity(0.3), lineWidth: selectedColor == color ? 4 : 0)
                                                .frame(width: 52, height: 52)
                                        )
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        
                        // 9. Reminders (Multi-Select)
                        VStack(alignment: .leading, spacing: 8) {
                            labelView("REMINDERS")
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundStyle(Color.blue.opacity(0.7))
                                    .padding(10)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Notify me")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(Color.adaptivePrimaryText)
                                    Text("Before event starts")
                                        .font(.caption)
                                        .foregroundStyle(Color.adaptiveSecondaryText)
                                }
                                
                                Spacer()
                                
                                Menu {
                                    // Multi-selection Options
                                    Button {
                                        toggleOffset(0)
                                    } label: {
                                        Label("At time of event", systemImage: selectedNotificationOffsets.contains(0) ? "checkmark" : "")
                                    }
                                    Button {
                                        toggleOffset(5)
                                    } label: {
                                        Label("5 minutes before", systemImage: selectedNotificationOffsets.contains(5) ? "checkmark" : "")
                                    }
                                    Button {
                                        toggleOffset(15)
                                    } label: {
                                        Label("15 minutes before", systemImage: selectedNotificationOffsets.contains(15) ? "checkmark" : "")
                                    }
                                    Button {
                                        toggleOffset(30)
                                    } label: {
                                        Label("30 minutes before", systemImage: selectedNotificationOffsets.contains(30) ? "checkmark" : "")
                                    }
                                    Button {
                                        toggleOffset(60)
                                    } label: {
                                        Label("1 hour before", systemImage: selectedNotificationOffsets.contains(60) ? "checkmark" : "")
                                    }
                                    Button {
                                        toggleOffset(1440)
                                    } label: {
                                        Label("1 day before", systemImage: selectedNotificationOffsets.contains(1440) ? "checkmark" : "")
                                    }
                                    
                                    Divider()
                                    
                                    Button(role: .destructive) {
                                        selectedNotificationOffsets.removeAll()
                                    } label: {
                                        Label("Clear All", systemImage: "trash")
                                    }
                                } label: {
                                    HStack {
                                        Text(reminderText)
                                            .foregroundStyle(Color.adaptivePrimaryText)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                        Image(systemName: "chevron.down")
                                            .font(.caption)
                                            .foregroundStyle(Color.adaptiveSecondaryText)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.adaptiveSecondaryText.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .padding()
                            .background(Color.adaptiveSecondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(20)
                }
                .background(Color.adaptiveGroupedBackground) // Main Background
                .scrollDismissesKeyboard(.interactively)
                
            }
            .navigationTitle("Create Event")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture {
                hideKeyboard()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.adaptivePrimaryText)
                            .font(.system(size: 16, weight: .bold))
                            .padding(6)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        saveEvent()
                    } label: {
                        Image(systemName: "checkmark")
                            
                            .foregroundStyle(Color.white)
                            .font(.system(size: 16, weight: .bold))
                            .padding(6)
                            .background(title.isEmpty ? Color.clear : selectedColor)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .disabled(title.isEmpty)
                }
            }
            .onAppear(perform: loadEventData)
            .sheet(isPresented: $showingCalendarPicker) {
                BatchCalendarImportView(onImport: { selectedEvents in
                    if let ekEvent = selectedEvents.first {
                        title = ekEvent.title
                        date = ekEvent.startDate
                        note = ekEvent.notes ?? ""
                        location = ekEvent.location ?? ""
                    }
                }, singleSelect: true)
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
            .sheet(isPresented: $showingDatePicker) {
                VStack {
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 4)
                        .padding(.top, 10)
                    
                    Text("Select Date")
                        .font(.headline)
                        .padding(.vertical)
                    
                    CustomDatePicker(date: $date, color: UIColor(selectedColor))
                        .frame(height: 200)
                        .padding(.horizontal)
                    
                    Button {
                        showingDatePicker = false
                    } label: {
                        Text("Done")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedColor)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding()
                }
                .presentationDetents([.height(350)])
                .presentationCornerRadius(24)
            }
            .sheet(isPresented: $showingTimePicker) {
                VStack {
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 4)
                        .padding(.top, 10)
                    
                    Text("Select Time")
                        .font(.headline)
                        .padding(.vertical)
                    
                    CustomTimePicker(date: $date, color: UIColor(selectedColor))
                        .frame(height: 200)
                    
                    Button {
                        showingTimePicker = false
                    } label: {
                        Text("Done")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedColor)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding()
                }
                .presentationDetents([.height(350)])
                .presentationCornerRadius(24)
            }
        }
        .alert("Duplicate Event", isPresented: $showDuplicateAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("An event with \(title) and \(date) already exists.")
        }
    }
    
    // MARK: - Subviews
    
    private var coverPhotoSection: some View {
        Button {
            // Trigger photo picker handled by invisible picker or distinct logic
        } label: {
            ZStack {
                if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                    let screenWidth = UIScreen.main.bounds.width
                    // Padding is 20 + 20 = 40
                    let width = screenWidth - 40
                    // Height ratio: same as detail view (300/Screen)
                    let height = width * (300 / screenWidth)
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: height)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.adaptiveSecondaryBackground, lineWidth: 4)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [10]))
                        .fill(Color.adaptiveSecondaryText.opacity(0.3))
                        .frame(height: 220)
                        .background(Color.adaptiveSecondaryText.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(Color.adaptiveSecondaryText)
                            .padding(20)
                            .background(Color.adaptiveSecondaryBackground)
                            .clipShape(Circle())
                        
                        Text("Add Cover Photo")
                            .font(.headline)
                            .foregroundStyle(Color.adaptiveSecondaryText)
                    }
                }
            }
        }
        .overlay {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Color.clear // Invisible overlay to trigger picker
            }
            .onChange(of: selectedItem) { newItem in
                 Task {
                     if let data = try? await newItem?.loadTransferable(type: Data.self),
                        let uiImage = UIImage(data: data) {
                         tempImage = uiImage
                         showingImageCropper = true
                         selectedItem = nil 
                     }
                 }
            }
        }
    }
    
    private func labelView(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(Color.adaptiveSecondaryText)
            .padding(.leading, 4)
    }
    
    // MARK: - Logic
    
    private func toggleOffset(_ minutes: Int) {
        if selectedNotificationOffsets.contains(minutes) {
            selectedNotificationOffsets.remove(minutes)
        } else {
            selectedNotificationOffsets.insert(minutes)
        }
    }

    private var reminderText: String {
        if selectedNotificationOffsets.isEmpty { return "None" }
        let sorted = selectedNotificationOffsets.sorted()
        if sorted.count == 1 {
            let val = sorted.first!
            if val == 0 { return "At time" }
            if val < 60 { return "\(val) min" }
            if val == 60 { return "1 hour" }
            if val == 1440 { return "1 day" }
            return "\(val) min"
        } else {
            return "\(sorted.count) selected"
        }
    }
    
    private var sortedCategories: [EventCategory] {
        let otherCategories = EventCategory.allCases.filter { $0 != category }
        let sorted = otherCategories.sorted { $0.displayName < $1.displayName }
        return [category] + sorted
    }
    
    private func loadEventData() {
        if let event = eventToEdit {
            title = event.title
            date = event.date
            category = event.category
            selectedColor = Color(hex: event.colorHex) ?? Color(hex: "#800080") ?? .purple
            note = event.note ?? ""
            location = event.location ?? ""
            if !event.notificationOffsets.isEmpty {
                selectedNotificationOffsets = Set(event.notificationOffsets)
            } else if let legacy = event.notifyBefore {
                selectedNotificationOffsets = [legacy]
            } else {
                selectedNotificationOffsets = []
            }
            selectedImageData = event.imageData
        }
    }
    
    private func saveEvent() {
        // Duplicate check
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if existingEvents.contains(where: {
            $0.title.trimmingCharacters(in: .whitespacesAndNewlines).caseInsensitiveCompare(trimmedTitle) == .orderedSame &&
            Calendar.current.isDate($0.date, equalTo: date, toGranularity: .minute) &&
            (eventToEdit == nil || $0.id != eventToEdit!.id)
        }) {
            showDuplicateAlert = true
            return
        }
        
        let hex = selectedColor.toHex() ?? "#F5A623"
        let sortedOffsets = Array(selectedNotificationOffsets).sorted()
        
        // Define finalEvent to capture the object for syncing
        let finalEvent: Event
        
        if let event = eventToEdit {
            event.title = title
            event.date = date
            event.category = category
            event.colorHex = hex
            event.note = note.isEmpty ? nil : note
            event.location = location.isEmpty ? nil : location
            event.notificationOffsets = sortedOffsets
            event.notifyBefore = sortedOffsets.first // legacy sync
            event.imageData = selectedImageData
            
            finalEvent = event
        } else {
            let newEvent = Event(
                title: title,
                date: date,
                note: note.isEmpty ? nil : note,
                category: category,
                colorHex: hex,
                notifyBefore: sortedOffsets.first, // Legacy param
                notificationOffsets: sortedOffsets, // New param
                imageData: selectedImageData,
                location: location.isEmpty ? nil : location
            )
            modelContext.insert(newEvent)
            finalEvent = newEvent
        }
        
        NotificationService.shared.scheduleNotification(for: finalEvent)
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
        
        // Sync to Cloud
        CloudKitService.shared.syncEvent(finalEvent)
        
        dismiss()
    }
    
    
}

// MARK: - Helpers & Extensions

extension Color {
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        if a != 1.0 {
            return String(format: "#%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
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


// MARK: - Keyboard Helper
//extension View {
//    func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//}

