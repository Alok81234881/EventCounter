import SwiftUI
import UIKit

struct CustomDatePicker: UIViewRepresentable {
    @Binding var date: Date
    var color: UIColor = UIColor(Color(hex: "#800080") ?? .purple)

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        
        // WORKAROUND REMOVED: Reverting to standard system look (Black/Gray)
        // picker.setValue(color, forKey: "textColor")
        // picker.setValue(false, forKey: "highlightsToday")
        
        picker.addTarget(context.coordinator, action: #selector(Coordinator.dateChanged), for: .valueChanged)
        return picker
    }
    
    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        // Prevent feedback loop: only update if time difference is significant
        if abs(uiView.date.timeIntervalSince(date)) > 60 {
             uiView.setDate(date, animated: true)
        }
    }
    
    class Coordinator: NSObject {
        var parent: CustomDatePicker
        
        init(_ parent: CustomDatePicker) {
            self.parent = parent
        }
        
        @objc func dateChanged(_ sender: UIDatePicker) {
            parent.date = sender.date
        }
    }
}
