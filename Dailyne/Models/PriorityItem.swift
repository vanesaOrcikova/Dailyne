//
//  PriorityItem.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 28/12/2025.
//

import Foundation

struct PriorityItem: Identifiable {
    let id: UUID = UUID()
    var title: String
    var isDone: Bool = false
}

