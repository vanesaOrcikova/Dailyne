//
//  VisionModels.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 28/01/2026.
//

import Foundation

enum VBStatus: String, Codable, CaseIterable {
    case someday
    case inProgress
    case achieved

    var title: String {
        switch self {
        case .someday: return "Someday"
        case .inProgress: return "In progress"
        case .achieved: return "Achieved"
        }
    }
}

enum VBLayout: String, Codable, CaseIterable {
    case portrait
    case landscape
}

struct VBItem: Identifiable, Codable {
    var id: UUID = UUID()
    var photoFilename: String

    var notes: String = ""
    var status: VBStatus = .inProgress

    var layout: VBLayout = .portrait 
    var createdAt: Date = Date()
}

struct VBCategory: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var items: [VBItem] = []
}
