//
//  Subject.swift
//  SoftLifePlanner
//
//  Created by Vanesa Orcikova on 28/12/2025.
//

import Foundation

struct Subject: Identifiable, Codable {
    let id: UUID
    var name: String
    var tasks: [SchoolTask]

    init(id: UUID = UUID(), name: String, tasks: [SchoolTask] = []) {
        self.id = id
        self.name = name
        self.tasks = tasks
    }
}
