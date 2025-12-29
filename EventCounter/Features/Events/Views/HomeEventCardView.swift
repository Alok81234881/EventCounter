import SwiftUI

struct HomeEventCardView: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: 16) {
            // 1. Icon Circle
            ZStack {
                Circle()
                    .fill(Color(hex: event.colorHex)?.opacity(0.1) ?? .blue.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30) // Smaller than circle
                        .clipShape(Circle())
                } else {
                    Image(systemName: event.category.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(Color(hex: event.colorHex) ?? .blue)
                }
            }
            
            // 2. Middle Info
            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.black)
                
                HStack(spacing: 8) {
                    Text(event.date.formatted(.dateTime.month().day()))
                        .font(.system(size: 13))
                        .foregroundStyle(.black.opacity(0.6))
                    
                    // Category Tag
                    Text(event.category.rawValue.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color(hex: event.colorHex) ?? .blue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color(hex: event.colorHex)?.opacity(0.15) ?? .blue.opacity(0.15))
                        )
                }
            }
            
            Spacer()
            
            // 3. Right Side - Days Left Circle
            if event.date > .now {
                // Upcoming: "14 DAYS"
                VStack(spacing: 0) {
                    let components = Calendar.current.dateComponents([.day], from: .now, to: event.date)
                    let days = max(0, components.day ?? 0)
                    
                    Text("\(days)")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(Color(hex: event.colorHex) ?? .blue)
                    
                    Text("DAYS")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.gray)
                }
                .frame(width: 50, height: 50)
                .background(Color(white: 0.97)) // Very light gray/white circle
                .clipShape(Circle())
            } else {
                // Past: "1 year ago" text (no circle per mockup logic for memory lane, but mockup shows card with "1 year ago" text on right)
                // Let's match the "Memory Lane" card in mockup: "Summer BBQ ... 3 mo ago"
                Text(event.date, style: .relative)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.gray) +
                Text(" ago")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.gray)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 4)
        )
    }
}
