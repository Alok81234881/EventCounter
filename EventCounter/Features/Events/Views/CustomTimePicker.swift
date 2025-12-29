import SwiftUI
import UIKit

struct CustomTimePicker: UIViewRepresentable {
    @Binding var date: Date
    var color: UIColor = .orange
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIView(_ uiView: UIPickerView, context: Context) {
        // Sync generic state if needed, but mostly relying on reloading for color updates
        // We need to set initial selection based on `date` only if not interacting?
        // To avoid loops, we check if calendar matches
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        let isPM = hour >= 12
        let displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
        let displayMinute = minute
        
        // Hour (0-11 for 1-12)
        if uiView.selectedRow(inComponent: 0) != (displayHour % 12 == 0 ? 11 : displayHour - 1) {
            uiView.selectRow(displayHour % 12 == 0 ? 11 : displayHour - 1, inComponent: 0, animated: false)
        }
        
        // Minute (0-59)
        if uiView.selectedRow(inComponent: 1) != displayMinute {
            uiView.selectRow(displayMinute, inComponent: 1, animated: false)
        }
        
        // AM/PM (0-1)
        if uiView.selectedRow(inComponent: 2) != (isPM ? 1 : 0) {
            uiView.selectRow(isPM ? 1 : 0, inComponent: 2, animated: false)
        }
    }
    
    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: CustomTimePicker
        
        init(_ parent: CustomTimePicker) {
            self.parent = parent
        }
        
        // Data Sources
        let hours = Array(1...12)
        let minutes = Array(0...59)
        let meridiems = ["AM", "PM"]
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 3
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            switch component {
            case 0: return hours.count
            case 1: return minutes.count
            case 2: return meridiems.count
            default: return 0
            }
        }
        
        // Delegate - Views with Color
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = (view as? UILabel) ?? UILabel()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
            
            // Determine text
            var text = ""
            switch component {
            case 0: text = "\(hours[row])"
            case 1: text = String(format: "%02d", minutes[row])
            case 2: text = meridiems[row]
            default: break
            }
            label.text = text
            
            // COLOR LOGIC: Check if this row is the selected one
            // We use the picker's current selected row.
            // Note: This method is called when scrolling. Creating a live "highlight center" effect.
            // Problem: `selectedRow(inComponent:)` returns the *stopped* selection or current index.
            // `pickerView` doesn't always redraw non-selected rows during scroll immediately unless we reload.
            // But for standard "wheel" feel, usually the focus line is separate.
            // User request: "Scroll to next time then that time should be in color".
            // Implementation: We check if `row == pickerView.selectedRow(inComponent: component)`.
            
            if row == pickerView.selectedRow(inComponent: component) {
                label.textColor = parent.color
                label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
            } else {
                label.textColor = .gray
            }
            
            return label
        }
        
        // Handling Selection
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            // Update the bound Date
            var calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: parent.date)
            
            // Get current selections from picker, to ensure consistency
            let selectedHourIndex = pickerView.selectedRow(inComponent: 0)
            let selectedMinuteIndex = pickerView.selectedRow(inComponent: 1)
            let selectedMeridiemIndex = pickerView.selectedRow(inComponent: 2)
            
            let h = hours[selectedHourIndex]
            let m = minutes[selectedMinuteIndex]
            let isPM = selectedMeridiemIndex == 1
            
            // Convert 12h to 24h
            var hour24 = h
            if isPM && h != 12 { hour24 += 12 }
            else if !isPM && h == 12 { hour24 = 0 }
            
            components.hour = hour24
            components.minute = m
            
            if let newDate = calendar.date(from: components) {
                parent.date = newDate
            }
            
            // Force refresh to update colors (Selected becomes Orange, others Gray)
            pickerView.reloadComponent(component)
        }
        
        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            return 32
        }
    }
}
