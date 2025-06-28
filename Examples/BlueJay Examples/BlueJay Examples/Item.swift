//
//  Item.swift
//  BlueJay Examples
//
//  Created by David Taylor on 4/25/25.
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
