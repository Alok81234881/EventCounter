import SwiftUI
import UIKit

struct CustomDatePicker: UIViewRepresentable {
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
        // CRITICAL: Update parent reference to keep binding/color fresh
        context.coordinator.parent = self
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        // Wrappping in async to allow UI layout cycle to complete and DataSource to be queried.
        DispatchQueue.main.async {
            // Reload updates component counts
            uiView.reloadAllComponents()
            
            // Safety Check
            guard uiView.numberOfComponents >= 3 else { return }
            
            // Year (Component 2)
            let baseYear = context.coordinator.baseYear
            let yearIndex = year - baseYear
            if yearIndex >= 0 && yearIndex < context.coordinator.years.count {
                if uiView.selectedRow(inComponent: 2) != yearIndex {
                    uiView.selectRow(yearIndex, inComponent: 2, animated: false)
                }
            }
            
            // Month (Component 0) - 0 to 11
            if uiView.selectedRow(inComponent: 0) != month - 1 {
                uiView.selectRow(month - 1, inComponent: 0, animated: false)
            }
            
            // Day (Component 1) - 1 to 31
            let numRows = uiView.numberOfRows(inComponent: 1)
            let dayIndex = day - 1
            
            if dayIndex >= 0 && dayIndex < numRows {
                if uiView.selectedRow(inComponent: 1) != dayIndex {
                    uiView.selectRow(dayIndex, inComponent: 1, animated: false)
                }
            } else if numRows > 0 {
                uiView.selectRow(numRows - 1, inComponent: 1, animated: false)
            }
        }
    }
    
    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: CustomDatePicker
        
        let baseYear = 2020
        var years: [Int] {
            return Array(baseYear...2050)
        }
        let months = Calendar.current.monthSymbols
        
        init(_ parent: CustomDatePicker) {
            self.parent = parent
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 3 // Month, Day, Year
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            switch component {
            case 0: return months.count
            case 1:
                // Calculate days in selected month/year
                let selectedMonth = pickerView.selectedRow(inComponent: 0) + 1
                let selectedYearIndex = pickerView.selectedRow(inComponent: 1)
                
                // Safety check for year index
                let safeYearIndex = max(0, min(selectedYearIndex, years.count - 1))
                let selectedYear = baseYear + safeYearIndex
                
                var components = DateComponents()
                components.year = selectedYear
                components.month = selectedMonth
                
                let calendar = Calendar.current
                if let date = calendar.date(from: components),
                   let range = calendar.range(of: .day, in: .month, for: date) {
                    return range.count
                }
                return 31
            case 2: return years.count
            default: return 0
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = (view as? UILabel) ?? UILabel()
            label.textAlignment = .center
            
            var text = ""
            switch component {
            case 0: 
                if row < months.count { text = months[row] }
            case 1: 
                text = "\(row + 1)"
            case 2: 
                if row < years.count { text = "\(years[row])" }
            default: break
            }
            
            // Year/Month alignment
            if component == 0 { label.textAlignment = .center }
            
            label.text = text
            
            // Safe selection check
            if row == pickerView.selectedRow(inComponent: component) {
                label.textColor = parent.color
                label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
            } else {
                label.textColor = .gray
                label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
            }
            
            return label
        }
        
        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            switch component {
            case 0: return 140
            case 1: return 60
            case 2: return 80
            default: return 50
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            // Update Day Count if Month/Year changed
            if component == 0 || component == 2 {
                pickerView.reloadComponent(1)
            }
            
            let selectedMonth = pickerView.selectedRow(inComponent: 0) + 1
            let selectedYearIndex = pickerView.selectedRow(inComponent: 2)
            let safeYearIndex = max(0, min(selectedYearIndex, years.count - 1))
            let selectedYear = baseYear + safeYearIndex
            
            // Validate Day Selection
            var components = DateComponents()
            components.year = selectedYear
            components.month = selectedMonth
            
            let calendar = Calendar.current
            var maxDays = 31
            if let date = calendar.date(from: components),
               let range = calendar.range(of: .day, in: .month, for: date) {
                maxDays = range.count
            }
            
            let currentDayIndex = pickerView.selectedRow(inComponent: 1)
            var selectedDay = currentDayIndex + 1
            
            if selectedDay > maxDays {
                selectedDay = maxDays
                pickerView.selectRow(maxDays - 1, inComponent: 1, animated: true)
            }
            
            // Update Binding
            var newComponents = DateComponents()
            newComponents.year = selectedYear
            newComponents.month = selectedMonth
            newComponents.day = selectedDay
            
            let timeComponents = calendar.dateComponents([.hour, .minute], from: parent.date)
            newComponents.hour = timeComponents.hour
            newComponents.minute = timeComponents.minute
            
            if let newDate = calendar.date(from: newComponents) {
                // Check if binding changed to avoid loop
                if newDate != parent.date {
                    parent.date = newDate
                }
            }
            
            // Reload to update colors
            pickerView.reloadComponent(component)
        }
        
        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            return 32
        }
    }
}
