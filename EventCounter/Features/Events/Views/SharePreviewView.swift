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
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Share Event")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(Color.adaptivePrimaryText)
                            Text("Preview your card")
                                .font(.system(size: 15))
                                .foregroundStyle(Color.adaptiveSecondaryText)
                        }
                        
                        Spacer()
                        
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.adaptiveSecondaryText)
                                .frame(width: 32, height: 32)
                                .background(Color.adaptiveSecondaryText.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 20)
                
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
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 480)
                
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
                    .background(Color(red: 0.11, green: 0.11, blue: 0.15))
                    .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // Cancel Button
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.adaptiveSecondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
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
        let width: CGFloat = 1020
        let height: CGFloat = 1320
        
        let cardView = ShareCardTemplate(event: event, components: components, templateStyle: style)
            .frame(width: width, height: height)
            .background(Color.white)
        
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
