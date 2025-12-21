import SwiftUI
import UIKit

struct ImageCropperView: View {
    let image: UIImage
    var onCrop: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    private let cropSize: CGFloat = 300
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                ZStack {
                    // Gray background for the non-cropped area
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                    
                    // The image to be cropped
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
                    
                    // The crop area overlay
                    Rectangle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: cropSize, height: cropSize)
                        .background(Color.black.opacity(0.001)) // Allows background tap
                        .allowsHitTesting(false)
                    
                    // Blurred out area outside the crop circle
                    maskOverlay()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                
                Spacer()
                
                Text("Pinch to zoom • Drag to move")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
            }
            .background(Color.black)
            .navigationTitle("Crop Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        cropAndSave()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
    
    @ViewBuilder
    private func maskOverlay() -> some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black.opacity(0.5)))
            
            let rect = CGRect(
                x: (size.width - cropSize) / 2,
                y: (size.height - cropSize) / 2,
                width: cropSize,
                height: cropSize
            )
            
            context.blendMode = .destinationOut
            context.fill(Path(rect), with: .color(.white))
        }
        .allowsHitTesting(false)
    }
    
    private func cropAndSave() {
        let imageSize = image.size
        let viewPortSize = CGSize(width: cropSize, height: cropSize)
        
        // Calculate the scale of the image as displayed in the UI (scaledToFill)
        let imageAspectRatio = imageSize.width / imageSize.height
        let screenWidth = UIScreen.main.bounds.width
        
        var displaySize: CGSize
        if imageAspectRatio > 1 {
            // Landscape
            displaySize = CGSize(width: screenWidth * imageAspectRatio, height: screenWidth)
        } else {
            // Portrait or Square
            displaySize = CGSize(width: screenWidth, height: screenWidth / imageAspectRatio)
        }
        
        // Final scale including user pinch zoom
        let totalScale = scale * (displaySize.width / imageSize.width)
        
        // Rendering
        let renderer = UIGraphicsImageRenderer(size: viewPortSize)
        let cropped = renderer.image { context in
            context.cgContext.translateBy(x: viewPortSize.width / 2, y: viewPortSize.height / 2)
            
            // Apply scale
            context.cgContext.scaleBy(x: scale, y: scale)
            
            // Apply translation offset
            context.cgContext.translateBy(x: offset.width / scale, y: offset.height / scale)
            
            // The image should be drawn centered in the coordinate system we just established
            let drawRect = CGRect(
                x: -displaySize.width / 2,
                y: -displaySize.height / 2,
                width: displaySize.width,
                height: displaySize.height
            )
            
            image.draw(in: drawRect)
        }
        
        onCrop(cropped)
        dismiss()
    }
}

#Preview {
    ImageCropperView(image: UIImage(systemName: "photo")!) { _ in }
}
