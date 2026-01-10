import SwiftUI

struct ShareCardTemplate: View {
    let event: Event
    let components: CountdownComponents
    let templateStyle: ShareCardStyle
    let scale: CGFloat = 1.0
    
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
//            case .circular:
//                CircularTemplate(event: event, components: components)
            case .iconPill:
                IconPillTemplate(event: event, components: components)
//            case .eventTicket:
//                EventTicketTemplate(event: event, components: components)
            case .cleanPhoto:
                CleanPhotoTemplate(event: event, components: components)
            case .heroOverlay:
                HeroOverlayTemplate(event: event, components: components)
            case .handwritten:
                HandwrittenTemplate(event: event, components: components)
            case .horizontalSplit:
                HorizontalSplitTemplate(event: event, components: components)
            case .checkIn:
                CheckInTemplate(event: event, components: components)
            case .cornerBubble:
                CornerBubbleTemplate(event: event, components: components)
            case .simpleIcon:
                SimpleIconTemplate(event: event, components: components)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// MARK: - Template 1: Hero Image
struct HeroImageTemplate: View {
    let event: Event
    let components: CountdownComponents
    let scale: CGFloat = 1.0
    
    var body: some View {
        VStack {
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
           
            
           
        }
        
        .overlay {
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .overlay(alignment: .center) {
            VStack(spacing: 16 * scale) {
               
                
                Text("UPCOMING")
                    .font(.system(size: 12 * scale, weight: .bold))
                    .foregroundStyle(.white.opacity(0.8))
                    .tracking(2)
                
                Text(event.title)
                    .font(.system(size: 42 * scale, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 20 * scale)
                
                HStack(spacing: 24 * scale) {
                    TimeUnitColumn(value: components.shareDisplayUnits[0].value, label: components.shareDisplayUnits[0].label)
                    TimeUnitColumn(value: components.shareDisplayUnits[1].value, label: components.shareDisplayUnits[1].label)
                    TimeUnitColumn(value: components.shareDisplayUnits[2].value, label: components.shareDisplayUnits[2].label)
                }
                .padding(.bottom, 60 * scale)
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
                if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140, height: 140)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white, lineWidth: 4))
                        .shadow(radius: 10)
                } else {
                    Image(systemName: event.category.icon)
                        .font(.system(size: 60))
                        .foregroundStyle(.white)
                }
                
                Text(event.title)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 20)
                
                VStack(spacing: 12) {
                    Text(components.naturalDescription(category: event.category, title: event.title))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 20) {
                        GradientUnit(value: components.shareDisplayUnits[0].value, label: components.shareDisplayUnits[0].label.capitalized)
                        Text(":").font(.system(size: 32, weight: .bold)).foregroundStyle(.white)
                        GradientUnit(value: components.shareDisplayUnits[1].value, label: components.shareDisplayUnits[1].label.capitalized)
                        Text(":").font(.system(size: 32, weight: .bold)).foregroundStyle(.white)
                        GradientUnit(value: components.shareDisplayUnits[2].value, label: components.shareDisplayUnits[2].label.capitalized)
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
                        if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color(hex: event.colorHex)?.opacity(0.1) ?? .blue.opacity(0.1))
                                .frame(width: 100, height: 100)
                            Image(systemName: event.category.icon)
                                .font(.system(size: 44))
                                .foregroundStyle(Color(hex: event.colorHex) ?? .blue)
                        }
                    }
                    
                    Text(event.title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.6)
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
                        .lineLimit(2)
                        .minimumScaleFactor(0.6)
                        .padding(.horizontal, 20)
                        
                    if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.top, 10)
                    }
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
                        .lineLimit(2)
                        .minimumScaleFactor(0.6)
                    
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
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
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
                    HStack(spacing: 30) {
                        CircularUnit(value: components.shareDisplayUnits[0].value, label: components.shareDisplayUnits[0].label)
                        CircularUnit(value: components.shareDisplayUnits[1].value, label: components.shareDisplayUnits[1].label)
                        CircularUnit(value: components.shareDisplayUnits[2].value, label: components.shareDisplayUnits[2].label)
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

// MARK: - Template 7: Icon Pill (Image 0)
struct IconPillTemplate: View {
    let event: Event
    let components: CountdownComponents
    
    var body: some View {
        ZStack {
            Color(hex: "#F5F5F7") ?? .white // Off-white background
            
            VStack(spacing: 0) {
                // Pill
                Text(event.date.formatted(date: .abbreviated, time: .omitted).uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.1, green: 0.1, blue: 0.2)) // Dark navy
                    .clipShape(Capsule())
                    .padding(.top, 40)
                
                Spacer()
                    .frame(height: 20)
                
                Text(event.title)
                    .font(.system(size: 42, weight: .black))
                    .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.2))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal)
                
                Text(event.category.displayName.uppercased())
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.gray)
                    .tracking(2)
                    .padding(.top, 8)
                
                Spacer()
                
                // Icon Gradient Box
                ZStack {
                    RoundedRectangle(cornerRadius: 40)
                        .fill(
                            LinearGradient(
                                colors: [Color.orange, Color.pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: .pink.opacity(0.3), radius: 20, y: 10)
                    
                    if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 140, height: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 40))
                    } else {
                        Image(systemName: event.category.icon)
                            .font(.system(size: 60))
                            .foregroundStyle(.white)
                    }
                    
                    if event.imageData == nil {
                        // Underline only if icon
                        Capsule()
                            .fill(.white)
                            .frame(width: 60, height: 6)
                            .offset(y: 45)
                    }
                }
                
                Spacer()
                
                // Countdown
                HStack(spacing: 0) {
                    VStack(spacing: 4) {
                        Text(components.shareDisplayUnits[0].value)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.2))
                        Text(components.shareDisplayUnits[0].label)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.gray.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    
                    Rectangle() // Divider
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 1, height: 40)
                    
                    VStack(spacing: 4) {
                        Text(components.shareDisplayUnits[1].value)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.2))
                        Text(components.shareDisplayUnits[1].label)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.gray.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    
                    Rectangle() // Divider
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 1, height: 40)
                    
                    VStack(spacing: 4) {
                        Text(components.shareDisplayUnits[2].value)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.2))
                        Text(components.shareDisplayUnits[2].label)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.gray.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(24)
                .background(Color.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Template 8: Event Ticket (Image 1)
struct EventTicketTemplate: View {
    let event: Event
    let components: CountdownComponents
    
    var body: some View {
        ZStack {
            Color.white
            
            VStack(spacing: 0) {
                // Top Half (Image)
                GeometryReader { geo in
                    ZStack(alignment: .topTrailing) {
                        if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width)
                                .clipped()
                        } else {
                            Rectangle()
                                .fill(Color(hex: event.colorHex) ?? .blue)
                                .overlay(
                                     LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .center, endPoint: .bottom)
                                )
                        }
                        
                        // Tag
                        Text("#20492")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.black.opacity(0.4))
                            .clipShape(Capsule())
                            .padding(16)
                        
                        // Pass Label
                        VStack(alignment: .leading) {
                           Text("EVENT PASS")
                              .font(.system(size: 12, weight: .bold))
                              .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.2))
                              .padding(.horizontal, 12)
                              .padding(.vertical, 8)
                              .background(Color.white)
                              .clipShape(Capsule())
                              .padding(.top, 16)
                              .padding(.leading, 16)
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.title)
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundStyle(.white)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.6)
                                
                                HStack {
                                    Image(systemName: "calendar")
                                    Text("\(event.date.formatted(date: .abbreviated, time: .omitted).uppercased()) • \(event.category.displayName.uppercased())")
                                }
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.white.opacity(0.9))
                            }
                            .padding(20)
                            .padding(.bottom, 10) // Space for cutouts
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(height: 260)
                .mask(
                    TicketShape(top: true)
                )
                
                // Perforated Line
                HStack(spacing: 6) {
                    ForEach(0..<30) { _ in
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 6, height: 2)
                    }
                }
                .frame(height: 2)
                .padding(.horizontal, 20)
                
                // Bottom Half (Details)
                VStack(spacing: 20) {
                    Text("VALID UNTIL")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.gray.opacity(0.6))
                        .tracking(2)
                        .padding(.top, 30)
                    
                    HStack(spacing: 20) {
                        TicketUnit(value: components.shareDisplayUnits[0].value, label: components.shareDisplayUnits[0].label, color: .orange)
                        Rectangle().fill(.gray.opacity(0.1)).frame(width: 1, height: 40)
                        TicketUnit(value: components.shareDisplayUnits[1].value, label: components.shareDisplayUnits[1].label, color: Color(red: 0.1, green: 0.1, blue: 0.2))
                        Rectangle().fill(.gray.opacity(0.1)).frame(width: 1, height: 40)
                        TicketUnit(value: components.shareDisplayUnits[2].value, label: components.shareDisplayUnits[2].label, color: Color(red: 0.1, green: 0.1, blue: 0.2))
                    }
                    
                    Spacer()
                    
                    // Faux Barcode
                    HStack(spacing: 3) {
                        ForEach(0..<40) { i in
                            Rectangle()
                                .fill(Color.gray.opacity(0.4))
                                .frame(width: Double.random(in: 2...5), height: 40)
                        }
                    }
                    .frame(height: 40)
                    .padding(.bottom, 30)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .mask(TicketShape(top: false))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TicketUnit: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.gray.opacity(0.6))
                .tracking(1)
        }
    }
}

struct TicketShape: Shape {
    let top: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius: CGFloat = 20
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        
        // Cutouts
        if top {
            path.addArc(center: CGPoint(x: 0, y: rect.height), radius: radius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
            path.addArc(center: CGPoint(x: rect.width, y: rect.height), radius: radius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
        } else {
            path.addArc(center: CGPoint(x: 0, y: 0), radius: radius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
            path.addArc(center: CGPoint(x: rect.width, y: 0), radius: radius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
        }
        
        return path
    }
}


// MARK: - Template 9: Clean Photo (Image 2)
struct CleanPhotoTemplate: View {
    let event: Event
    let components: CountdownComponents
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color(hex: event.colorHex) ?? .blue)
                         .overlay(
                             Image(systemName: event.category.icon)
                                 .font(.system(size: 80))
                                 .foregroundStyle(.white)
                         )
                }
            }
            .frame(height: 300) // Square-ish
            
            VStack(spacing: 16) {
                Text(event.title)
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.2))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                
                HStack(spacing: 16) {
                    VStack {
                        Text(components.shareDisplayUnits[0].value)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.2))
                        Text(components.shareDisplayUnits[0].label)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.gray)
                    }
                    Rectangle().fill(.gray.opacity(0.2)).frame(width: 1, height: 30)
                    VStack {
                        Text(components.shareDisplayUnits[1].value)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.2))
                        Text(components.shareDisplayUnits[1].label)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.gray)
                    }
                     Rectangle().fill(.gray.opacity(0.2)).frame(width: 1, height: 30)
                    VStack {
                        Text(components.shareDisplayUnits[2].value)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.2))
                        Text(components.shareDisplayUnits[2].label)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.gray)
                    }
                }
                .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}


// MARK: - Template 10: Hero Overlay (Image 3)
struct HeroOverlayTemplate: View {
    let event: Event
    let components: CountdownComponents
    
    var body: some View {
        ZStack {
            // Background
            GeometryReader { geo in
                if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color(hex: event.colorHex) ?? .blue)
                }
            }
            
            // White Gradient Overlay from bottom
             LinearGradient(
                 colors: [.white, .white.opacity(0.8), .white.opacity(0.0)],
                 startPoint: .bottom,
                 endPoint: .center
             )
            
            VStack {
                Spacer()
                
                // Content
                VStack(spacing: 8) {
                    Text("UPCOMING")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.bottom, 8)
                    
                    Text(event.title)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.2))
                    
                    Text(event.category.displayName)
                        .font(.system(size: 18))
                        .foregroundStyle(.gray)
                        .padding(.bottom, 24)
                    
                    HStack(spacing: 24) {
                        HeroUnit(value: components.shareDisplayUnits[0].value, label: components.shareDisplayUnits[0].label)
                        Rectangle().fill(.gray.opacity(0.2)).frame(width: 1, height: 40)
                            .rotationEffect(.degrees(15))
                        HeroUnit(value: components.shareDisplayUnits[1].value, label: components.shareDisplayUnits[1].label)
                         Rectangle().fill(.gray.opacity(0.2)).frame(width: 1, height: 40)
                            .rotationEffect(.degrees(15))
                        HeroUnit(value: components.shareDisplayUnits[2].value, label: components.shareDisplayUnits[2].label)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct HeroUnit: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 38, weight: .bold))
                .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.2))
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.gray.opacity(0.8))
        }
    }
}


// MARK: - Template 11: Handwritten (Image 4)
struct HandwrittenTemplate: View {
    let event: Event
    let components: CountdownComponents
    
    var body: some View {
        ZStack {
            Color.white
            
            VStack(spacing: 0) {
                // Photo
                GeometryReader { geo in
                    if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color(hex: event.colorHex) ?? .blue)
                            .overlay(Image(systemName: "photo").font(.largeTitle).foregroundColor(.white))
                    }
                }
                .frame(height: 280)
                .padding(24)
                
                VStack(spacing: 8) {
                    Text(event.title)
                        .font(.custom("BradleyHandITCTT-Bold", size: 42))
                        .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.25)) // Dark navy
                        .multilineTextAlignment(.center)
                    
                    Text(event.category.displayName)
                        .font(.custom("BradleyHandITCTT-Bold", size: 24))
                        .foregroundStyle(.gray)
                        .padding(.bottom, 24)
                    
                    HStack(spacing: 30) {
                        HandwrittenUnit(value: components.shareDisplayUnits[0].value, label: components.shareDisplayUnits[0].label.lowercased())
                        HandwrittenUnit(value: components.shareDisplayUnits[1].value, label: components.shareDisplayUnits[1].label.lowercased())
                        HandwrittenUnit(value: components.shareDisplayUnits[2].value, label: components.shareDisplayUnits[2].label.lowercased())
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct HandwrittenUnit: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 0) {
            Text(value)
                .font(.custom("BradleyHandITCTT-Bold", size: 36))
                .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.25))
            Text(label)
                .font(.custom("BradleyHandITCTT-Bold", size: 20))
                .foregroundStyle(.gray)
        }
    }
}

// MARK: - Template 12: Horizontal Split (Image 0)
struct HorizontalSplitTemplate: View {
    let event: Event
    let components: CountdownComponents
    
    var body: some View {
        ZStack {
            Color(hex: "#2C211B") ?? .black // Dark brown/black background
            
            VStack(spacing: 0) {
                // Top Image
                GeometryReader { geo in
                    if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color(hex: event.colorHex) ?? .blue)
                    }
                }
                .frame(height: 220)
                .overlay(alignment: .topTrailing) {
                     Text("UPCOMING")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .padding(20)
                }
                
                // Bottom Content
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 60) // Space for overlapping title
                    
                    Text(event.category.displayName)
                        .font(.system(size: 18))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.bottom, 40)
                    
                    HStack(spacing: 30) {
                        SplitUnit(value: components.shareDisplayUnits[0].value, label: components.shareDisplayUnits[0].label)
                        Rectangle().fill(.white.opacity(0.2)).frame(width: 1, height: 40)
                        SplitUnit(value: components.shareDisplayUnits[1].value, label: components.shareDisplayUnits[1].label)
                        Rectangle().fill(.white.opacity(0.2)).frame(width: 1, height: 40)
                        SplitUnit(value: components.shareDisplayUnits[2].value, label: components.shareDisplayUnits[2].label)
                    }
                    .padding(.bottom, 40)
                }
            }
            
            // Overlapping Title
            Text(event.title.uppercased())
                .font(.system(size: 48, weight: .heavy))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 10)
                .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                .offset(y: -40) // Overlap the boundary
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SplitUnit: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
                .tracking(1)
        }
    }
}

// MARK: - Template 13: Check-In (Image 1)
struct CheckInTemplate: View {
    let event: Event
    let components: CountdownComponents
    
    var body: some View {
        ZStack {
            Color.white
            
            // Dot pattern background (simulated)
            GeometryReader { geo in
                HStack(spacing: 20) {
                    ForEach(0..<Int(geo.size.width / 20), id: \.self) { _ in
                        VStack(spacing: 20) {
                            ForEach(0..<Int(geo.size.height / 20), id: \.self) { _ in
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 2, height: 2)
                            }
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            VStack(spacing: 24) {
                // Header
                HStack(alignment: .top, spacing: 16) {
                    // Photo
                    if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                Image(systemName: event.category.icon)
                                    .font(.system(size: 16))
                                    .foregroundStyle(.white)
                                    .frame(width: 32, height: 32)
                                    .background(Color.orange)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    .offset(x: 10, y: 10),
                                alignment: .bottomTrailing
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: event.colorHex) ?? .blue)
                            .frame(width: 80, height: 80)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CHECKING IN")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.gray)
                            .tracking(1)
                        
                        Text(event.title)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.2))
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                        
                        Text(event.category.displayName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                }
                .padding(.top, 40)
                .padding(.horizontal, 24)
                
                // Flight/Info Card
                VStack(spacing: 16) {
                    HStack {
                        Text("DEPARTING IN")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.gray)
                        Spacer()
                        HStack(spacing: 4) {
                            Circle().fill(.green).frame(width: 6, height: 6)
                            Text("CONFIRMED")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.green)
                        }
                    }
                    
                    HStack(spacing: 0) {
                        CheckInUnit(value: components.shareDisplayUnits[0].value, label: components.shareDisplayUnits[0].label)
                        Rectangle().fill(.gray.opacity(0.1)).frame(width: 1, height: 40)
                        CheckInUnit(value: components.shareDisplayUnits[1].value, label: components.shareDisplayUnits[1].label)
                        Rectangle().fill(.gray.opacity(0.1)).frame(width: 1, height: 40)
                        CheckInUnit(value: components.shareDisplayUnits[2].value, label: components.shareDisplayUnits[2].label)
                    }
                }
                .padding(24)
                .background(Color(hex: "#F5F7F9") ?? .gray.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Footer / QR
                HStack {
                    Text("#\(event.title.uppercased().prefix(4))-2024")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.gray.opacity(0.6))
                    Spacer()
                    Image(systemName: "qrcode")
                        .font(.system(size: 30))
                        .foregroundStyle(.gray.opacity(0.4))
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CheckInUnit: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.2))
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Template 14: Corner Bubble (Image 2)
struct CornerBubbleTemplate: View {
    let event: Event
    let components: CountdownComponents
    
    var body: some View {
        ZStack {
            // Background
            GeometryReader { geo in
                if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color(hex: event.colorHex) ?? .blue)
                }
            }
            
            // Dark Overlay
            Color.black.opacity(0.2)
            
            VStack(alignment: .leading) {
                // Top Pill
                 HStack {
                     Image(systemName: "party.popper.fill")
                        .font(.system(size: 12))
                     Text("UPCOMING")
                        .font(.system(size: 12, weight: .bold))
                 }
                 .foregroundStyle(.white)
                 .padding(.horizontal, 16)
                 .padding(.vertical, 8)
                 .background(.white.opacity(0.2))
                 .clipShape(Capsule())
                 .overlay(Capsule().stroke(.white.opacity(0.3), lineWidth: 1))
                 .padding(24)
                
                Spacer()
                
                Text(event.title)
                    .font(.system(size: 46, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .shadow(radius: 10)
                
                Text(event.category.displayName)
                    .font(.system(size: 20))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Bottom Right Bubble
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("TIME LEFT")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.gray)
                                .tracking(1)
                            Spacer()
                            Circle().fill(.pink).frame(width: 6, height: 6)
                        }
                        
                        HStack(spacing: 16) {
                            BubbleUnit(value: components.shareDisplayUnits[0].value, label: components.shareDisplayUnits[0].label)
                            BubbleUnit(value: components.shareDisplayUnits[1].value, label: components.shareDisplayUnits[1].label)
                            BubbleUnit(value: components.shareDisplayUnits[2].value, label: components.shareDisplayUnits[2].label)
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .padding(16)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct BubbleUnit: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.2))
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.gray)
        }
    }
}

// MARK: - Template 15: Simple Icon (Image 3)
struct SimpleIconTemplate: View {
    let event: Event
    let components: CountdownComponents
    
    var body: some View {
        ZStack {
            Color.white
            
            VStack(spacing: 0) {
                Spacer()
                
                // Icon Circle
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.1))
                        .frame(width: 80, height: 80)
                    Image(systemName: event.category.icon)
                        .font(.system(size: 32))
                        .foregroundStyle(.orange)
                }
                .padding(.bottom, 30)
                
                Text(event.title)
                    .font(.system(size: 42, weight: .bold, design: .serif))
                    .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.2))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text(event.category.displayName.uppercased())
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.gray.opacity(0.6))
                    .tracking(2)
                    .padding(.top, 12)
                
                Spacer()
                
                HStack(spacing: 40) {
                    SimpleUnit(value: components.shareDisplayUnits[0].value, label: components.shareDisplayUnits[0].label)
                     Rectangle().fill(.gray.opacity(0.1)).frame(width: 1, height: 40)
                    SimpleUnit(value: components.shareDisplayUnits[1].value, label: components.shareDisplayUnits[1].label)
                     Rectangle().fill(.gray.opacity(0.1)).frame(width: 1, height: 40)
                    SimpleUnit(value: components.shareDisplayUnits[2].value, label: components.shareDisplayUnits[2].label)
                }
                .padding(.bottom, 60)
                
                Text("EventCount")
                    .font(.system(size: 12))
                    .foregroundStyle(.gray.opacity(0.3))
                    .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SimpleUnit: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.2))
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.gray.opacity(0.4))
                .tracking(1)
        }
    }
}

#Preview {
    HeroImageTemplate(event: Event(title: "test event", date: Date()), components: .init(months: 1, days: 1, hours: 1, minutes: 1, seconds: 1, isPast: false, isCountUp: false))
}
