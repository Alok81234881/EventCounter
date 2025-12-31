import SwiftUI
import EventKit

struct BatchCalendarImportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var events: [EKEvent] = []
    @State private var selectedEventIDs: Set<String> = []
    @State private var isLoading = false
    
    let onImport: ([EKEvent]) -> Void
    var singleSelect: Bool = false
    
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
                    Button(selectedEventIDs.count == events.count ? "Deselect All" : "Select All") {
                        if selectedEventIDs.count == events.count {
                            selectedEventIDs.removeAll()
                        } else {
                            selectedEventIDs = Set(events.map { $0.eventIdentifier })
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.orange)
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
                                                .foregroundStyle(isSelected ? .orange : Color.adaptiveSecondaryText)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(event.title)
                                                    .font(.system(size: 17, weight: .bold))
                                                    .foregroundStyle(Color.adaptivePrimaryText)
                                                
                                                Text(event.startDate.formatted(date: .abbreviated, time: .shortened))
                                                    .font(.system(size: 14))
                                                    .foregroundStyle(Color.adaptiveSecondaryText)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: isSelected ? (singleSelect ? "largecircle.fill.circle" : "checkmark.circle.fill") : "circle")
                                                .font(.system(size: 20))
                                                .foregroundStyle(isSelected ? (singleSelect ? .orange : .green) : Color.adaptiveSecondaryText.opacity(0.3))
                                        }
                                        .padding()
                                        .background(Color.adaptiveSecondaryBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: 24))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(isSelected ? .orange.opacity(0.5) : Color.clear, lineWidth: 2)
                                        )
                                        .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
                                    }
                                    .buttonStyle(.plain)
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
                        .background(selectedEventIDs.isEmpty ? Color.gray.opacity(0.5) : Color.orange)
                        .clipShape(Capsule())
                        .shadow(color: selectedEventIDs.isEmpty ? .clear : .orange.opacity(0.3), radius: 10, y: 5)
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
