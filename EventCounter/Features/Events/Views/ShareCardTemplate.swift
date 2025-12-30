import SwiftUI

struct ShareCardTemplate: View {
    let event: Event
    let components: CountdownComponents
    let templateStyle: ShareCardStyle
    
    var body: some View {
        Group {
            switch templateStyle {
            case .heroImage:
                HeroImageTemplate(event: event, components: components)
            case .gradient:
                GradientTemplate(event: event, components: components)
            case .minimal:
                MinimalTemplate(event: event, components: components)
            case .dark:
                DarkTemplate(event: event, components: components)
            case .polaroid:
                PolaroidTemplate(event: event, components: components)
            case .circular:
                CircularTemplate(event: event, components: components)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// MARK: - Template 1: Hero Image
struct HeroImageTemplate: View {
    let event: Event
    let components: CountdownComponents
    
    var body: some View {
        ZStack {
            // Background Image/Color
            GeometryReader { geo in
                if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: event.colorHex) ?? .blue, Color(hex: event.colorHex)?.opacity(0.6) ?? .blue.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            
            // Dark gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            VStack(spacing: 16) {
                Spacer()
                
                Text("UPCOMING")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.8))
                    .tracking(2)
                
                Text(event.title)
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                HStack(spacing: 24) {
                    TimeUnitColumn(value: "\(components.days)", label: "DAYS")
                    TimeUnitColumn(value: String(format: "%02d", components.hours), label: "HRS")
                    TimeUnitColumn(value: String(format: "%02d", components.minutes), label: "MINS")
                }
                .padding(.bottom, 60)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TimeUnitColumn: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.8))
        }
    }
}

// MARK: - Template 2: Gradient
struct GradientTemplate: View {
    let event: Event
    let components: CountdownComponents
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: event.colorHex) ?? .purple,
                    Color(hex: event.colorHex)?.opacity(0.7) ?? .purple.opacity(0.7),
                    Color(hex: event.colorHex)?.opacity(0.4) ?? .purple.opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 24) {
                Image(systemName: event.category.icon)
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
                
                Text(event.title)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                VStack(spacing: 12) {
                    Text(components.naturalDescription(category: event.category, title: event.title))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 20) {
                        GradientUnit(value: "\(components.days)", label: "Days")
                        Text(":").font(.system(size: 32, weight: .bold)).foregroundStyle(.white)
                        GradientUnit(value: String(format: "%02d", components.hours), label: "Hours")
                        Text(":").font(.system(size: 32, weight: .bold)).foregroundStyle(.white)
                        GradientUnit(value: String(format: "%02d", components.minutes), label: "Mins")
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct GradientUnit: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.8))
        }
    }
}

// MARK: - Template 3: Minimal
struct MinimalTemplate: View {
    let event: Event
    let components: CountdownComponents
    
    var body: some View {
        ZStack {
            Color.white
            
            VStack(spacing: 40) {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: event.colorHex)?.opacity(0.1) ?? .blue.opacity(0.1))
                            .frame(width: 100, height: 100)
                        Image(systemName: event.category.icon)
                            .font(.system(size: 44))
                            .foregroundStyle(Color(hex: event.colorHex) ?? .blue)
                    }
                    
                    Text(event.title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    Text(event.date.formatted(date: .long, time: .shortened))
                        .font(.system(size: 16))
                        .foregroundStyle(.gray)
                }
                
                VStack(spacing: 20) {
                    Text("TIME REMAINING")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.gray)
                        .tracking(2)
                    
                    HStack(spacing: 16) {
                        MinimalBox(value: "\(components.days)", label: "Days", color: Color(hex: event.colorHex) ?? .blue)
                        MinimalBox(value: String(format: "%02d", components.hours), label: "Hours", color: Color(hex: event.colorHex) ?? .blue)
                        MinimalBox(value: String(format: "%02d", components.minutes), label: "Mins", color: Color(hex: event.colorHex) ?? .blue)
                    }
                }
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MinimalBox: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Template 4: Dark
struct DarkTemplate: View {
    let event: Event
    let components: CountdownComponents
    
    var body: some View {
        ZStack {
            Color(red: 0.11, green: 0.11, blue: 0.15)
            
            VStack(spacing: 40) {
                VStack(spacing: 16) {
                    Text(event.category.displayName.uppercased())
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(hex: event.colorHex) ?? .cyan)
                        .tracking(3)
                    
                    Text(event.title)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                HStack(spacing: 16) {
                    CountdownBox(value: "\(components.days)", label: "DAYS", color: Color(hex: event.colorHex) ?? .cyan)
                    CountdownBox(value: String(format: "%02d", components.hours), label: "HRS", color: Color(hex: event.colorHex) ?? .cyan)
                    CountdownBox(value: String(format: "%02d", components.minutes), label: "MIN", color: Color(hex: event.colorHex) ?? .cyan)
                }
                .padding(.horizontal, 24)
                
                if let location = event.location, !location.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(Color(hex: event.colorHex) ?? .cyan)
                        Text(location)
                            .font(.system(size: 16))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Template 5: Polaroid
struct PolaroidTemplate: View {
    let event: Event
    let components: CountdownComponents
    
    var body: some View {
        ZStack {
            Color(hex: "#F5F5F0") ?? Color(white: 0.96)
            
            VStack(spacing: 0) {
                // Photo Section
                GeometryReader { geo in
                    ZStack {
                        if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.width)
                                .clipped()
                        } else {
                            Rectangle()
                                .fill(Color(hex: event.colorHex) ?? .blue)
                            Image(systemName: event.category.icon)
                                .font(.system(size: 80))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .padding(24)
                .background(Color.white)
                
                // Caption Section
                VStack(spacing: 16) {
                    Text(event.title)
                        .font(.custom("Bradley Hand", size: 28))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 16) {
                        Text("\(components.days) days")
                        Text("\(components.hours) hrs")
                        Text("\(components.minutes) mins")
                    }
                    .font(.custom("Bradley Hand", size: 22))
                    .foregroundStyle(.black.opacity(0.7))
                }
                .padding(.vertical, 32)
                .frame(maxWidth: .infinity)
                .background(Color.white)
            }
            .padding(20)
            .background(Color.white)
            .shadow(color: .black.opacity(0.15), radius: 20, y: 15)
            .rotationEffect(.degrees(-2))
            .padding(40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Template 6: Circular
struct CircularTemplate: View {
    let event: Event
    let components: CountdownComponents
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.white, Color(hex: "#F8F8F8") ?? .gray.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            VStack(spacing: 40) {
                Text(event.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                ZStack {
                    CircularProgressView(
                        progress: event.progress,
                        color: Color(hex: event.colorHex) ?? .blue,
                        lineWidth: 24
                    )
                    .padding(30)
                    
                    VStack(spacing: 8) {
                        Text("\(Int(event.progress * 100))%")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(Color(hex: event.colorHex) ?? .blue)
                        Text("Complete")
                            .font(.system(size: 16))
                            .foregroundStyle(.gray)
                    }
                }
                .frame(width: 300, height: 300)
                
                VStack(spacing: 16) {
                    HStack(spacing: 32) {
                        CircularUnit(value: "\(components.days)", label: "Days")
                        CircularUnit(value: String(format: "%02d", components.hours), label: "Hours")
                        CircularUnit(value: String(format: "%02d", components.minutes), label: "Mins")
                    }
                    
                    Text(event.date.formatted(date: .long, time: .shortened))
                        .font(.system(size: 15))
                        .foregroundStyle(.gray)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CircularUnit: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.black)
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(.gray)
        }
    }
}

struct CountdownBox: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white.opacity(0.6))
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
