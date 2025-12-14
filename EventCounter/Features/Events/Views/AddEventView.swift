import SwiftUI
import SwiftData
import UIKit

struct AddEventView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var date = Date()
    @State private var category: EventCategory = .personal
    @State private var selectedColor = Color.blue
    @State private var isPinned = false
    @State private var note = ""
    
    // Mapping Colors to Hex for simplicity.
    private let availableColors: [Color] = [.blue, .red, .green, .orange, .purple, .pink, .yellow]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Event Details") {
                    TextField("Title", text: $title)
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
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
                }
                
                Section("Notes") {
                    TextField("Optional notes", text: $note, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("New Event")
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
        }
    }
    
    private func saveEvent() {
        // Convert Color to Hex String
        let hex = selectedColor.toHex() ?? "#0000FF"
        
        let newEvent = Event(
            title: title,
            date: date,
            note: note.isEmpty ? nil : note,
            category: category,
            colorHex: hex,
            isPinned: isPinned
        )
        
        modelContext.insert(newEvent)
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
