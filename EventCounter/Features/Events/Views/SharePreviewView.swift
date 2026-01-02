import SwiftUI

struct SharePreviewView: View {
    @Environment(\.dismiss) private var dismiss
    let event: Event
    let components: CountdownComponents
    
    @State private var selectedTemplate = 0
    @State private var showingShareSheet = false
    @State private var shareImage: UIImage?
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 0) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color.adaptivePrimaryText)
                                .frame(width: 50, height: 50)
                                .background(Color.adaptiveSecondaryBackground)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        Spacer()
                        VStack {
                            Text("Share \(event.title)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(Color.adaptivePrimaryText)
                            Text("Preview your card")
                                .font(.system(size: 15))
                                .foregroundStyle(Color.adaptiveSecondaryText)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        Spacer()
                        Color.clear.frame(width: 50, height: 50)
                    }
                   
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 10)
                
                // Card Carousel
                TabView(selection: $selectedTemplate) {
                    ForEach(0..<6, id: \.self) { index in
                        ShareCardTemplate(
                            event: event,
                            components: components,
                            templateStyle: ShareCardStyle(rawValue: index) ?? .heroImage
                        )
                        .frame(width: 340, height: 440)
                        .tag(index)
                    }
                }
                .frame(height: 480)
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                HStack(spacing: 8) {
                    ForEach(0..<6, id: \.self) { index in
                        Circle()
                            .fill(index == selectedTemplate ? Color.primary : Color.secondary.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 8)
                
                // Share Button
                Button {
                    generateAndShare()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Share")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: event.colorHex) ?? .blue)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 20)

                
//                // Cancel Button
//                Button {
//                    dismiss()
//                } label: {
//                    Text("Cancel")
//                        .font(.system(size: 17, weight: .medium))
//                        .foregroundStyle(Color.adaptiveSecondaryText)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 16)
//                }
//                .padding(.horizontal, 24)
//                .padding(.bottom, 24)
            }
            .background(Color.adaptiveSecondaryBackground)
            .cornerRadius(24)
            .padding(.horizontal, 16)
            .padding(.vertical, 60)
        }
        .sheet(isPresented: $showingShareSheet) {
            if let image = shareImage {
                ShareSheet(items: [image])
            }
        }
    }
    
    private func generateAndShare() {
        let style = ShareCardStyle(rawValue: selectedTemplate) ?? .heroImage
        
        // Exact 3x scale of the 340x440 preview card to ensure layout is identical
        let width: CGFloat = 340
        let height: CGFloat = 440
        
        let cardView = ShareCardTemplate(event: event, components: components, templateStyle: style)
            .frame(width: width, height: height)
            .background(Color.clear)
        
        let renderer = ImageRenderer(content: cardView)
        renderer.proposedSize = .init(width: width, height: height)
        renderer.scale = 1.0 
        
        if let image = renderer.uiImage {
            shareImage = image
            showingShareSheet = true
        }
    }
}

// Share Sheet wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

enum ShareCardStyle: Int {
    case heroImage = 0
    case gradient = 1
    case minimal = 2
    case dark = 3
    case polaroid = 4
    case circular = 5
}
#Preview {
    SharePreviewView(
        event: Event(title: "test", date: Date()),
        components: .init(months: 3, days: 3, hours: 3, minutes: 3, seconds: 3, isPast: false, isCountUp: false)
    )
}
