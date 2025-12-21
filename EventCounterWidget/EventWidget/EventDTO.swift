import Foundation

struct EventDTO {
    let title: String
    let date: Date
    let categoryIcon: String
    let colorHex: String
    let imageData: Data?
    var isCountUp: Bool = false
    let categoryRaw: String
}
