//
//  Item.swift
//  EventCounter
//
//  Created by Alok SIngh on 14/12/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
