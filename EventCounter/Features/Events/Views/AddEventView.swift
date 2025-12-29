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
    
    // MARK: - State Properties
    @State private var title = ""
    @State private var date = Date()
    @State private var location = ""
    @State private var note = ""
    @State private var category: EventCategory = .personal
    @State private var selectedColor = Color.orange // Default per mockup (Travel/Orange)
    @State private var notifyBefore: Int? = 15 // Default 15 min per mockup
    
    // Image Handling
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showingImageCropper = false
    @State private var tempImage: UIImage?
    
    // Calendar Import
    @State private var showingCalendarPicker = false
    @State private var showingTimePicker = false
    @State private var showingDatePicker = false
    @State private var calendarEvents: [EKEvent] = []
    @State private var isLoadingEvents = false
    
    // Mockup Colors
    private let availableColors: [Color] = [
        Color(hex: "#F5A623") ?? .orange, // Orange
        Color(hex: "#E04F97") ?? .pink,   // Pink
        Color(hex: "#9B51E0") ?? .purple, // Purple
        Color(hex: "#2F80ED") ?? .blue,   // Blue
        Color(hex: "#27AE60") ?? .green,  // Green
        Color(hex: "#2C3E50") ?? .black   // Dark
    ]
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // 1. Cover Photo Area
                        coverPhotoSection
                        
                        // 2. Event Name
                        VStack(alignment: .leading, spacing: 8) {
                            labelView("EVENT NAME")
                            HStack(spacing: 12) {
                                Image(systemName: "pencil")
                                    .foregroundStyle(.gray)
                                TextField("", text: $title, prompt: Text("e.g. Cabo Trip, Mom's Bday").foregroundColor(.gray))
                                    .foregroundStyle(.black)
                                    .submitLabel(.done)
                            }
                            .padding()
                            .background(Color.white)
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
                                            .foregroundStyle(.black)
                                        Spacer()
                                        Image(systemName: "calendar")
                                            .foregroundStyle(.gray)
                                    }
                                    .padding()
                                    .background(Color.white)
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
                                            .foregroundStyle(.black)
                                        Spacer()
                                        Image(systemName: "clock")
                                            .foregroundStyle(.gray)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .frame(height: 56)
                                }
                            }
                        }
                        
                        // 4. Location
                        VStack(alignment: .leading, spacing: 8) {
                            labelView("LOCATION")
                            HStack(spacing: 12) {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundStyle(.gray)
                                TextField("", text: $location, prompt: Text("e.g. Central Park, NY").foregroundColor(.gray))
                                    .foregroundStyle(.black)
                                    .submitLabel(.done)
                            }
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        // 5. Notes
                        VStack(alignment: .leading, spacing: 8) {
                            labelView("NOTES")
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "text.alignleft")
                                    .foregroundStyle(.gray)
                                    .padding(.top, 4)
                                TextField("", text: $note, prompt: Text("Add details, #hashtags, links...").foregroundColor(.gray), axis: .vertical)
                                    .foregroundStyle(.black)
                                    .submitLabel(.done)
                                    .lineLimit(3...6)
                            }
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        // 6. Import Button
                        Button {
                            importFromCalendar()
                        } label: {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                Text("Import from Calendar")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundStyle(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.blue.opacity(0.2), lineWidth: 1))
                        }
                        
                        // 7. Event Type
                        VStack(alignment: .leading, spacing: 12) {
                            labelView("EVENT TYPE")
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(EventCategory.allCases, id: \.self) { cat in
                                        Button {
                                            withAnimation { category = cat }
                                        } label: {
                                            HStack(spacing: 8) {
                                                Image(systemName: cat.icon)
                                                Text(cat.displayName)
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .background(category == cat ? Color.white : Color.white)
                                            .foregroundStyle(category == cat ? selectedColor : .gray)
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
                                                    .stroke(Color.white, lineWidth: 3)
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
                        
                        // 9. Reminders
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
                                        .foregroundStyle(.black)
                                    Text("Before event starts")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                
                                Spacer()
                                
                                Menu {
                                    Picker("Time", selection: $notifyBefore) {
                                        Text("None").tag(nil as Int?)
                                        Text("At time of event").tag(0 as Int?)
                                        Text("15 min").tag(15 as Int?)
                                        Text("30 min").tag(30 as Int?)
                                        Text("1 hour").tag(60 as Int?)
                                        Text("1 day").tag(1440 as Int?)
                                    }
                                } label: {
                                    HStack {
                                        Text(reminderText)
                                            .foregroundStyle(.black)
                                        Image(systemName: "chevron.down")
                                            .font(.caption)
                                            .foregroundStyle(.gray)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        // Bottom Padding
                        Color.clear.frame(height: 80)
                    }
                    .padding(20)
                }
                .background(Color(white: 0.98)) // Main Background
                .scrollDismissesKeyboard(.interactively)
                
                // Save Button
                Button(action: saveEvent) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Save Event")
                    }
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedColor)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .shadow(color: selectedColor.opacity(0.3), radius: 10, y: 5)
                }
                .padding()
                .padding(.bottom, 10) // Extra safety padding
                .background(
                    LinearGradient(
                        colors: [Color(white: 0.98).opacity(0), Color(white: 0.98)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .disabled(title.isEmpty)
                .opacity(title.isEmpty ? 0.6 : 1.0)
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
                            .foregroundStyle(.black)
                            .font(.system(size: 16, weight: .bold))
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
            }
            .preferredColorScheme(.light)
            .onAppear(perform: loadEventData)
            .sheet(isPresented: $showingCalendarPicker) {
                CalendarPickerView(events: calendarEvents) { ekEvent in
                    title = ekEvent.title
                    date = ekEvent.startDate
                    note = ekEvent.notes ?? ""
                    location = ekEvent.location ?? ""
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
    }
    
    // MARK: - Subviews
    
    private var coverPhotoSection: some View {
        Button {
            // Trigger photo picker handled by invisible picker or distinct logic
        } label: {
            ZStack {
                if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white, lineWidth: 4)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [10]))
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.gray)
                            .padding(20)
                            .background(Color.white)
                            .clipShape(Circle())
                        
                        Text("Add Cover Photo")
                            .font(.headline)
                            .foregroundStyle(.gray)
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
            .foregroundStyle(.gray)
            .padding(.leading, 4)
    }
    
    private var reminderText: String {
        guard let mins = notifyBefore else { return "None" }
        if mins == 0 { return "At time" }
        if mins == 15 { return "15 min" }
        if mins == 30 { return "30 min" }
        if mins == 60 { return "1 hour" }
        if mins == 1440 { return "1 day" }
        return "\(mins) min"
    }
    
    // MARK: - Logic
    
    private func loadEventData() {
        if let event = eventToEdit {
            title = event.title
            date = event.date
            category = event.category
            selectedColor = Color(hex: event.colorHex) ?? .orange
            note = event.note ?? ""
            location = event.location ?? ""
            notifyBefore = event.notifyBefore
            selectedImageData = event.imageData
        }
    }
    
    private func saveEvent() {
        let hex = selectedColor.toHex() ?? "#F5A623"
        
        if let event = eventToEdit {
            event.title = title
            event.date = date
            event.category = category
            event.colorHex = hex
            event.note = note.isEmpty ? nil : note
            event.location = location.isEmpty ? nil : location
            event.notifyBefore = notifyBefore
            event.imageData = selectedImageData
            
            NotificationService.shared.scheduleNotification(for: event)
        } else {
            let newEvent = Event(
                title: title,
                date: date,
                note: note.isEmpty ? nil : note,
                category: category,
                colorHex: hex,
                notifyBefore: notifyBefore,
                imageData: selectedImageData,
                location: location.isEmpty ? nil : location
            )
            modelContext.insert(newEvent)
            NotificationService.shared.scheduleNotification(for: newEvent)
        }
        
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
        dismiss()
    }
    
    private func importFromCalendar() {
        Task {
            isLoadingEvents = true
            calendarEvents = await CalendarService.shared.fetchUpcomingEvents()
            isLoadingEvents = false
            showingCalendarPicker = true
        }
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

struct CalendarPickerView: View {
    let events: [EKEvent]
    let onSelect: (EKEvent) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedEvent: EKEvent?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundStyle(.gray)
                
                Spacer()
                
                Text("Choose Event")
                    .font(.headline)
                    .foregroundStyle(.black)
                
                Spacer()
                
                // Balance
                Text("Cancel")
                    .foregroundStyle(.clear)
            }
            .padding()
            .background(Color(white: 0.98))
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("UPCOMING EVENTS")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.gray)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    if events.isEmpty {
                        ContentUnavailableView(
                            "No Calendar Events",
                            systemImage: "calendar.badge.exclamationmark",
                            description: Text("No upcoming events found.")
                        )
                        .padding(.top, 40)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(events, id: \.eventIdentifier) { event in
                                let isSelected = selectedEvent?.eventIdentifier == event.eventIdentifier
                                
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedEvent = event
                                    }
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "calendar")
                                            .font(.system(size: 20))
                                            .foregroundStyle(isSelected ? .orange : .gray)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(event.title)
                                                .font(.system(size: 17, weight: .bold))
                                                .foregroundStyle(.black)
                                            
                                            Text(event.startDate.formatted(date: .abbreviated, time: .shortened))
                                                .font(.system(size: 14))
                                                .foregroundStyle(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                                            .font(.system(size: 20))
                                            .foregroundStyle(isSelected ? .blue : .gray.opacity(0.5))
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
                                    )
                                    .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 100)
            }
            .background(Color(white: 0.96))
            .overlay(alignment: .bottom) {
                // Import Button
                if !events.isEmpty {
                    Button {
                        if let selected = selectedEvent {
                            onSelect(selected)
                        }
                    } label: {
                        HStack {
                            Text("Import Event")
                                .fontWeight(.bold)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedEvent == nil ? Color.gray.opacity(0.5) : Color.orange)
                        .clipShape(Capsule())
                    }
                    .disabled(selectedEvent == nil)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color(white: 0.96).opacity(0), Color(white: 0.96)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
        }
    }
}

// MARK: - Keyboard Helper
//extension View {
//    func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//}
