//
//  SchoolTask.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 28/12/2025.
//

import Foundation

enum SchoolTaskType: String, CaseIterable, Identifiable, Codable {
    case assignment = "Assignment"
    case study = "Study"
    case points = "Points"

    var id: String { rawValue }
}

enum TaskPriority: Int, CaseIterable, Identifiable, Codable {
    case normal = 0
    case important = 1
    case urgent = 2

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .normal: return ""
        case .important: return "!"
        case .urgent: return "!!!"
        }
    }
}

struct SchoolTask: Identifiable, Codable {
    let id: UUID

    var title: String
    var note: String            // ✅ nová poznámka
    var isDone: Bool
    var type: SchoolTaskType

    // priority len pre assignment + study
    var priority: TaskPriority

    // Assignment
    var dueDate: Date?

    // Points
    var pointsEarned: Int?
    var pointsTotal: Int?

    init(
        id: UUID = UUID(),
        title: String,
        note: String = "",
        isDone: Bool = false,
        type: SchoolTaskType = .assignment,
        priority: TaskPriority = .normal,
        dueDate: Date? = nil,
        pointsEarned: Int? = nil,
        pointsTotal: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.isDone = isDone
        self.type = type
        self.priority = priority
        self.dueDate = dueDate
        self.pointsEarned = pointsEarned
        self.pointsTotal = pointsTotal
    }
}
