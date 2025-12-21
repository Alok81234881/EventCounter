import SwiftUI

struct CircularProgressView: View {
    let progress: Double // 0.0 to 1.0
    let color: Color
    var lineWidth: CGFloat = 8
    var showBackground: Bool = true
    
    var body: some View {
        ZStack {
            if showBackground {
                Circle()
                    .stroke(color.opacity(0.1), lineWidth: lineWidth)
            }
            
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: progress)
        }
    }
}
