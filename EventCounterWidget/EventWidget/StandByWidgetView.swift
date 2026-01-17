import SwiftUI
import WidgetKit

struct StandByWidgetView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        Group {
            if let event = entry.event {
                switch family {
                case .systemSmall:
                    StandBySmallView(event: event, entryDate: entry.date)
                default:
                    StandByMediumView(event: event, entryDate: entry.date)
                }
            } else {
                VStack {
                    Text("Select Event")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Long press to edit")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
        }
        .containerBackground(for: .widget) {
            Color.black
        }
    }
}

// MARK: - Medium View (Landscape Clock)
struct StandByMediumView: View {
    let event: EventDTO
    let entryDate: Date
    
    var body: some View {
        HStack(spacing: 20) {
            // Left: Big Days Count
            let components = CountdownService.calculateComponents(from: entryDate, to: event.date, isCountUp: event.isCountUp)
            let days = (components.months * 30) + components.days
            
            VStack(spacing: -5) {
                Text("\(days)")
                    .font(.system(size: 80, weight: .thin, design: .serif))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hex: "#E0B0FF") ?? .purple, // Mauve
                                Color(hex: "#DA70D6") ?? .pink    // Orchid
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .contentTransition(.numericText())
                    .shadow(color: (Color(hex: "#DA70D6") ?? .pink).opacity(0.5), radius: 10)
                
                Text(days == 1 ? "DAY" : "DAYS")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .tracking(4)
            }
            .frame(minWidth: 100)
            
            // Right: Details & Timer
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(size: 20, weight: .medium, design: .serif))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                // Neon Separator
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                    .frame(maxWidth: 100)
                    .padding(.bottom, 8)
                
                // Hybrid Live Timer + Labels
                VStack(spacing: 0) {
                    // Logic: Create a target date that is exactly (Hours + Mins + Secs) from now
                    // This forces the timer style to show HH:MM:SS or MM:SS, never Days
                    let totalInterval = event.date.timeIntervalSince(entryDate)
                    let remainder = totalInterval.truncatingRemainder(dividingBy: 86400)
                    // If remainder is negative (event passed), we handle count up logic or just show 0
                    let timerTarget = entryDate.addingTimeInterval(remainder)
                    
                    // 1. The Live Timer (Monospaced to ensure alignment)
                    // 1. The Live Timer
                    // We use a solid color for the timer to ensure reliable live updates (Gradients can sometimes freeze live text)
                    Text(timerTarget, style: .timer)
                        .font(.system(size: 42, weight: .light, design: .monospaced))
                        .foregroundStyle(Color(hex: "#E0B0FF") ?? .purple)
                        .shadow(color: (Color(hex: "#DA70D6") ?? .pink).opacity(0.5), radius: 10)
                        .multilineTextAlignment(.center)
                        .contentTransition(.numericText())
                    
                    // 2. The Labels (Manually aligned to match the timer roughly)
                    // Note: Since we can't perfectly align with a system timer string, we use varied spacing
                    HStack(spacing: 35) {
                        Text("HRS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white.opacity(0.3))
                        Text("MINS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white.opacity(0.3))
                        Text("SECS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    .padding(.top, -4) // Tuck barely under the numbers
                }
            }
           
        }
        .padding(.top, -10)
    }
}
            
            // MARK: - Small View
            // MARK: - Small View
            struct StandBySmallView: View {
                let event: EventDTO
                let entryDate: Date
                
                var body: some View {
                    let components = CountdownService.calculateComponents(from: entryDate, to: event.date, isCountUp: event.isCountUp)
                    let days = (components.months * 30) + components.days
                    
                    // Logic for Live Timer (excluding days)
                    let totalInterval = event.date.timeIntervalSince(entryDate)
                    let remainder = totalInterval.truncatingRemainder(dividingBy: 86400)
                    let timerTarget = entryDate.addingTimeInterval(remainder)
                    
                    VStack(spacing: 2) {
                        // 1. Title (2 Lines)
                        Text(event.title)
                            .font(.system(size: 14, weight: .medium, design: .serif))
                            .foregroundStyle(.white.opacity(0.9))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                        
                        Spacer()
                        
                        // 2. Big Days
                        VStack(spacing: -4) {
                            Text("\(days)")
                                .font(.system(size: 46, weight: .thin, design: .serif)) // Scaled down from 60
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "#E0B0FF") ?? .purple,
                                            Color(hex: "#DA70D6") ?? .pink
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .contentTransition(.numericText())
                                .shadow(color: (Color(hex: "#DA70D6") ?? .pink).opacity(0.4), radius: 8)
                            
                            Text(days == 1 ? "day" : "days")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        
                        Spacer()
                        
                        // 3. Live Timer (Scaled Down)
                        VStack(spacing: 0) {
                            Text(timerTarget, style: .timer)
                                .font(.system(size: 20, weight: .light, design: .monospaced))
                                .foregroundStyle(Color(hex: "#E0B0FF") ?? .purple)
                                .multilineTextAlignment(.center)
                                .shadow(color: (Color(hex: "#DA70D6") ?? .pink).opacity(0.5), radius: 6)
                            
                            HStack(spacing: 14) {
                                Text("HRS")
                                    .font(.system(size: 6, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.3))
                                Text("MINS")
                                    .font(.system(size: 6, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.3))
                                Text("SECS")
                                    .font(.system(size: 6, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.3))
                            }
                            .padding(.top, -2)
                        }
                        .padding(.bottom, 4)
                    }
                    .padding(.horizontal, 4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                }
            }
            
            // MARK: - Helpers
            struct NeonTimeBlock: View {
                let value: Int
                let label: String
                
                var body: some View {
                    VStack(spacing: 0) {
                        Text(String(format: "%02d", value))
                            .font(.system(size: 24, weight: .light, design: .monospaced))
                            .foregroundStyle(Color(hex: "#E0B0FF") ?? .purple)
                            .shadow(color: (Color(hex: "#E0B0FF") ?? .purple).opacity(0.3), radius: 4)
                        
                        Text(label)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
            }
            
            struct NeonTimeSeparator: View {
                var body: some View {
                    Text(":")
                        .font(.system(size: 20, weight: .light))
                        .foregroundStyle(.white.opacity(0.3))
                        .padding(.bottom, 8)
                }
            }
            
