import SwiftUI

struct SocialShareCardView: View {
    let event: Event
    let components: CountdownComponents
    
    var body: some View {
        ZStack {
            // Background
            if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 500, height: 500)
                    .overlay(Color.black.opacity(0.4))
            } else {
                LinearGradient(
                    colors: [Color(hex: event.colorHex) ?? .blue, .black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: 500, height: 500)
            }
            
            // Content Overlays
            VStack(spacing: 20) {
                Spacer()
                
                // Icon or Category
                Image(systemName: event.category.icon)
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .padding()
                    .background(Circle().fill(.white.opacity(0.2)))
                
                VStack(spacing: 8) {
                    Text(event.title)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text(event.date.formatted(date: .long, time: .shortened))
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Countdown Display
                HStack(spacing: 20) {
                    SocialTimeUnitView(value: components.days, unit: "DAYS")
                    SocialTimeUnitView(value: components.hours, unit: "HOURS")
                    SocialTimeUnitView(value: components.minutes, unit: "MINS")
                }
                .padding(.bottom, 40)
                
                // Branding
                HStack {
                    Image(systemName: "timer")
                    Text("EventCounter")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white.opacity(0.6))
                .padding(.bottom, 20)
            }
        }
        .frame(width: 500, height: 500)
        .clipShape(RoundedRectangle(cornerRadius: 0)) // Standard square for social
    }
}

private struct SocialTimeUnitView: View {
    let value: Int
    let unit: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 34, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            Text(unit)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(minWidth: 70)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 12).fill(.white.opacity(0.15)))
    }
}

#Preview {
    SocialShareCardView(
        event: Event(title: "New Year", date: Date().addingTimeInterval(3600*24*10)),
        components: CountdownComponents(days: 10, hours: 5, minutes: 30, seconds: 0, isPast: false, isCountUp: false)
    )
}
