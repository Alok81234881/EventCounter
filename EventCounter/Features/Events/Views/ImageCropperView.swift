import SwiftUI
import UIKit

struct ImageCropperView: View {
    let image: UIImage
    var onCrop: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    // Gestures State for the IMAGE (Standard Interaction)
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var previewSize: CGSize = .zero // Capture the screen/container size
    
    private let cropWidth: CGFloat = 350
    private let cropHeight: CGFloat = 200
    private let cornerLength: CGFloat = 20
    private let cornerThickness: CGFloat = 4
    private let cropColor = Color(hex: "#800080")
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.adaptivePrimaryText)
                        .padding()
                }
                
                Spacer()
                
                Text("Adjust Image")
                    .font(.headline)
                    .foregroundStyle(Color.adaptivePrimaryText)
                
                Spacer()
                
                Button {
                    cropAndSave()
                } label: {
                    Text("Use Image")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(cropColor)
                        .clipShape(Capsule())
                }
                .padding(.trailing, 16)
            }
            .padding(.top, 50) // Explicit Notch Padding
            .padding(.bottom, 10)
            .background(Color.adaptiveSecondaryBackground)
            .zIndex(100)
            
            // MARK: - Main Editor
            ZStack {
                // 1. Dark Background
                Color(white: 0.15).ignoresSafeArea()
                
                // 2. Movable Image
                // We clamp gestures so the image stays somewhat within bounds? 
                // Flexible crop usually allows free movement.
                GeometryReader { geometry in
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = lastScale * value
                                    }
                                    .onEnded { _ in
                                        lastScale = scale
                                    }
                            )
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .onAppear { previewSize = geometry.size }
                    .onChange(of: geometry.size) { previewSize = $0 }
                }
                
                // 3. Dimmed Mask (Overlay with Hole)
                maskOverlay()
                    .allowsHitTesting(false) // Let gestures pass through to image
                
                // 4. Crop Box Visuals (Grid + Corners)
                ZStack {
                    // Grid Lines (3x3)
                    VStack(spacing: 0) {
                        Spacer()
                        Divider().background(Color.white.opacity(0.3))
                        Spacer()
                        Divider().background(Color.white.opacity(0.3))
                        Spacer()
                    }
                    HStack(spacing: 0) {
                        Spacer()
                        Rectangle().fill(Color.white.opacity(0.3)).frame(width: 1)
                        Spacer()
                        Rectangle().fill(Color.white.opacity(0.3)).frame(width: 1)
                        Spacer()
                    }
                    
                    // Orange Corners
                    cornersView()
                }
                .frame(width: cropWidth, height: cropHeight)
                .allowsHitTesting(false)
            }
            .clipShape(Rectangle())
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color(white: 0.15))
    }
    
    // MARK: - Visual Components
    
    private func maskOverlay() -> some View {
        Canvas { context, size in
            // Fill entire screen with dark dim
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black.opacity(0.7)))
            
            // Create the hole for crop box
            let x = (size.width - cropWidth) / 2
            let y = (size.height - cropHeight) / 2
            let cropRect = CGRect(x: x, y: y, width: cropWidth, height: cropHeight)
            
            // Cut it out
            context.blendMode = .destinationOut
            context.fill(Path(cropRect), with: .color(.white))
        }
    }
    
    private func cornersView() -> some View {
        ZStack {
            // Top Left
            Path { path in
                path.move(to: CGPoint(x: 0, y: cornerLength))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: cornerLength, y: 0))
            }
            .stroke(cropColor ?? .purple, style: StrokeStyle(lineWidth: cornerThickness, lineCap: .butt, lineJoin: .miter))
            .frame(width: cropWidth, height: cropHeight)
            // Wait, path coordinates are absolute. We need to align them.
            // Using standard alignment on the ZStack
            
            // Let's use specific aligned Corner Views
            cornerPath(rotation: 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            cornerPath(rotation: 90)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            
            cornerPath(rotation: 180)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            
            cornerPath(rotation: 270)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
    }
    
    private func cornerPath(rotation: Double) -> some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: cornerLength))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: cornerLength, y: 0))
        }
        .stroke(cropColor ?? .purple, style: StrokeStyle(lineWidth: cornerThickness, lineCap: .butt, lineJoin: .miter))
        .frame(width: cornerLength, height: cornerLength)
        .rotationEffect(.degrees(rotation))
    }
    
    // MARK: - Logic
    
    private func cropAndSave() {
        // Render the image based on specific scale/offset transformations to a new context.
        // Or simpler: Render the View Content within the Crop Rect frame.
        
        let renderer = ImageRenderer(content:
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: previewSize.width, height: previewSize.height) // Match the screen geometry
                    .clipped() // Clip to screen bounds first if desired, but not strictly necessary for the center crop
                    .scaleEffect(scale)
                    .offset(offset)
            }
            .frame(width: cropWidth, height: cropHeight) // The "hole" cropping frame
            .clipped()
        )
        // Ensure scale matches screen scale for quality
        renderer.scale = 3.0 // High Quality
        
        if let uiImage = renderer.uiImage {
             onCrop(uiImage)
        }
        
        dismiss()
    }
}
