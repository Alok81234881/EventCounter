import SwiftUI
import EventKit
import SwiftData

struct BatchCalendarImportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var events: [EKEvent] = []
    @State private var selectedEventIDs: Set<String> = []
    @State private var isLoading = false
    
    @Query var existingEvents: [Event]
    
    let onImport: ([EKEvent]) -> Void
    var singleSelect: Bool = false
    
    private func isDuplicate(_ ekEvent: EKEvent) -> Bool {
        existingEvents.contains(where: { $0.title.trimmingCharacters(in: .whitespacesAndNewlines).caseInsensitiveCompare(ekEvent.title.trimmingCharacters(in: .whitespacesAndNewlines)) == .orderedSame && Calendar.current.isDate($0.date, equalTo: ekEvent.startDate, toGranularity: .minute) })
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundStyle(Color.adaptiveSecondaryText)
                
                Spacer()
                
                Text(singleSelect ? "Choose Event" : "Import Events")
                    .font(.headline)
                    .foregroundStyle(Color.adaptivePrimaryText)
                
                Spacer()
                
                if !singleSelect && !events.isEmpty {
                    Button(selectedEventIDs.count == events.filter { !isDuplicate($0) }.count ? "Deselect All" : "Select All") {
                        if selectedEventIDs.count == events.filter { !isDuplicate($0) }.count {
                            selectedEventIDs.removeAll()
                        } else {
                            selectedEventIDs = Set(events.filter { !isDuplicate($0) }.map { $0.eventIdentifier })
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(hex: "#800080") ?? .purple)
                } else {
                    Text("Cancel")
                        .foregroundStyle(.clear)
                }
            }
            .padding()
            .background(Color.adaptiveSecondaryBackground)
            
            ZStack {
                Color.adaptiveGroupedBackground.ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Fetching Calendar...")
                        .foregroundStyle(Color.adaptiveSecondaryText)
                } else if events.isEmpty {
                    ContentUnavailableView(
                        "No Calendar Events",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("No upcoming events found in your calendar.")
                    )
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("UPCOMING EVENTS")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.adaptiveSecondaryText)
                                .padding(.horizontal)
                                .padding(.top, 10)
                            
                            VStack(spacing: 12) {
                                ForEach(events, id: \.eventIdentifier) { event in
                                    let duplicate = isDuplicate(event)
                                    let isSelected = selectedEventIDs.contains(event.eventIdentifier)
                                    
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            if singleSelect {
                                                selectedEventIDs = [event.eventIdentifier]
                                            } else {
                                                if isSelected {
                                                    selectedEventIDs.remove(event.eventIdentifier)
                                                } else {
                                                    selectedEventIDs.insert(event.eventIdentifier)
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: "calendar")
                                                .font(.system(size: 20))
                                                .foregroundStyle(isSelected ? Color(hex: "#800080") ?? .purple : Color.adaptiveSecondaryText)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(event.title)
                                                    .font(.system(size: 17, weight: .bold))
                                                    .foregroundStyle(Color.adaptivePrimaryText)
                                                
                                                Text(event.startDate.formatted(date: .abbreviated, time: .shortened))
                                                    .font(.system(size: 14))
                                                    .foregroundStyle(Color.adaptiveSecondaryText)
                                            }
                                            
                                            Spacer()
                                            
                                            if duplicate {
                                                Image(systemName: "lock.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundStyle(.gray)
                                            } else {
                                                Image(systemName: isSelected ? (singleSelect ? "largecircle.fill.circle" : "checkmark.circle.fill") : "circle")
                                                    .font(.system(size: 20))
                                                    .foregroundStyle(isSelected ? (singleSelect ? Color(hex: "#800080") ?? .purple : .green) : Color.adaptiveSecondaryText.opacity(0.3))
                                            }
                                        }
                                        .padding()
                                        .background(duplicate ? Color.gray.opacity(0.18) : Color.adaptiveSecondaryBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: 24))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(isSelected ? Color(hex: "#800080")?.opacity(0.5) ?? .purple.opacity(0.5) : Color.clear, lineWidth: 2)
                                        )
                                        .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(duplicate)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 100)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if !events.isEmpty {
                    Button {
                        let selectedEvents = events.filter { selectedEventIDs.contains($0.eventIdentifier) }
                        onImport(selectedEvents)
                        dismiss()
                    } label: {
                        HStack {
                            Text(singleSelect ? "Import Event" : "Import \(selectedEventIDs.count) Selected")
                                .fontWeight(.bold)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedEventIDs.isEmpty ? Color.gray.opacity(0.5) : Color(hex: "#800080") ?? .purple)
                        .clipShape(Capsule())
                        .shadow(color: selectedEventIDs.isEmpty ? .clear : Color(hex: "#800080")?.opacity(0.3) ?? .purple, radius: 10, y: 5)
                    }
                    .disabled(selectedEventIDs.isEmpty)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.adaptiveGroupedBackground.opacity(0), Color.adaptiveGroupedBackground],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
        }
        .task {
            isLoading = true
            events = await CalendarService.shared.fetchUpcomingEvents()
            isLoading = false
        }
    }
}
