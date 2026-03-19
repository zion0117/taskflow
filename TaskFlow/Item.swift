//
//  Item.swift
//  TaskFlow
//
//  Created by suyeonkim on 3/19/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    var notes: String

    init(title: String, notes: String = "") {
        self.title = title
        self.isCompleted = false
        self.createdAt = Date()
        self.notes = notes
    }
}
