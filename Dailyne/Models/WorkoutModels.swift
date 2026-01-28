//
//  WorkoutModels.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 28/01/2026.
//

import Foundation

struct WorkoutSet: Identifiable, Codable {
    var id: UUID = UUID()
    var weight: String
    var reps: String
}

struct WorkoutExercise: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var notes: String = ""
    var sets: [WorkoutSet] = []
    var photoFilename: String? = nil  // ✅ fotka ako súbor
}

struct WorkoutDay: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var exercises: [WorkoutExercise] = []
}
