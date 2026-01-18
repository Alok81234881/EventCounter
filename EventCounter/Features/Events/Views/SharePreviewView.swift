import SwiftUI

struct SharePreviewView: View {
    @Environment(\.dismiss) private var dismiss
    let event: Event
    let components: CountdownComponents
    
    @State private var selectedTemplate = 0
    @State private var showingShareSheet = false
    @State private var shareImage: UIImage?
    @State private var shareURL: URL?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $selectedTemplate) {
                    ForEach(0..<18, id: \.self) { index in
                        ShareCardTemplate(
                            event: event,
                            components: components,
                            templateStyle: ShareCardStyle(rawValue: index) ?? .heroImage
                        )
                        .frame(width: 340, height: 440)
                        .tag(index)
                    }
                }
                .frame(height: 500)
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                HStack(spacing: 8) {
                    ForEach(0..<18, id: \.self) { index in
                        Circle()
                            .fill(index == selectedTemplate ? Color.primary : Color.secondary.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 15)
                .padding(.bottom, 15)
                
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
               
                .padding(.bottom, 30)
            }
          //  .padding(.top, -50)
            .toolbar {
                //.toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(Color.adaptivePrimaryText)
                                .font(.system(size: 16, weight: .bold))
                                .padding(6)
                        }
                    }
                ToolbarItem(placement: .title) {
                    VStack {
                        Text("Share \(event.title)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color.adaptivePrimaryText)
                        Text("Preview your card")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.adaptiveSecondaryText)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            //.navigationTitle("Share \(event.title)")
            //.navigationSubtitle("Preview and share your event")
            .background(Color.adaptiveSecondaryBackground.ignoresSafeArea())
            .sheet(isPresented: $showingShareSheet) {
                if let image = shareImage, let url = shareURL {
                    ShareSheet(items: [ShareActivityItemSource(shareImage: image, shareURL: url, eventTitle: event.title)])
                }
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
        renderer.scale = 3.0 // High quality output 
        
        if let image = renderer.uiImage {
            // Save to temporary file with custom name
            let sanitizedTitle = event.title.replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: "/", with: "-")
            let filename = "\(sanitizedTitle)_card.png"
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent(filename)
            
            do {
                if let data = image.pngData() {
                    try data.write(to: fileURL)
                    shareImage = image
                    shareURL = fileURL
                    showingShareSheet = true
                }
            } catch {
                print("Error saving share image: \(error)")
            }
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
   // case circular = 5
    case iconPill = 6
   // case eventTicket = 7
    case cleanPhoto = 8
    case heroOverlay = 9
    case handwritten = 10
    case horizontalSplit = 11
    case checkIn = 12
    case cornerBubble = 13
    //case simpleIcon = 14
 //   case modernBlur = 15
  //  case typographic = 16
    case notification = 17
}

import LinkPresentation

class ShareActivityItemSource: NSObject, UIActivityItemSource {
    let shareImage: UIImage
    let shareURL: URL
    let eventTitle: String
    
    init(shareImage: UIImage, shareURL: URL, eventTitle: String) {
        self.shareImage = shareImage
        self.shareURL = shareURL
        self.eventTitle = eventTitle
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return shareURL
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return shareURL
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = eventTitle
        metadata.iconProvider = NSItemProvider(object: shareImage)
        metadata.imageProvider = NSItemProvider(object: shareImage)
        return metadata
    }
}

#Preview {
    SharePreviewView(
        event: Event(title: "test", date: Date()),
        components: .init(months: 3, days: 3, hours: 3, minutes: 3, seconds: 3, isPast: false, isCountUp: false)
    )
}
