//
//  WorkoutPlanStore.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 23/01/2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class WorkoutPlanStore: ObservableObject {

    struct Day: Identifiable, Codable {
        var id: UUID = UUID()
        var title: String
        var exercises: [Exercise]
    }

    struct Exercise: Identifiable, Codable {
        var id: UUID = UUID()
        var name: String
        var photoData: Data? = nil
    }

    @Published var days: [Day] = [
        Day(title: "Day 1", exercises: [
            Exercise(name: "Squat"),
            Exercise(name: "Hip Thrust"),
            Exercise(name: "Lat Pulldown")
        ])
    ]

    @Published var selectedDayId: UUID?
    @Published var showAddExercise: Bool = false

    @Published var showExerciseDetail: Bool = false
    @Published var selectedExerciseId: UUID? = nil

    init() {
        selectedDayId = days.first?.id
    }

    var selectedDay: Day? {
        guard let id = selectedDayId else { return nil }
        return days.first(where: { $0.id == id })
    }

    // ✅ pridá kategóriu a vráti jej id (aby sme ju hneď vedeli pomenovať)
    func addDayAndReturnId() -> UUID {
        let new = Day(title: "New", exercises: [])
        days.append(new)
        selectedDayId = new.id
        return new.id
    }

    func renameDay(id: UUID, to newTitle: String) {
        if let index = days.firstIndex(where: { $0.id == id }) {
            days[index].title = newTitle
        }
    }

    func deleteDay(_ day: Day) {
        if days.count <= 1 { return } // necháme aspoň 1 kategóriu

        let wasSelected = (selectedDayId == day.id)
        days.removeAll { $0.id == day.id }

        if wasSelected {
            selectedDayId = days.first?.id
        }
    }

    func addExercise(name: String) {
        guard let id = selectedDayId else { return }
        guard let dayIndex = days.firstIndex(where: { $0.id == id }) else { return }

        let ex = Exercise(name: name)
        days[dayIndex].exercises.append(ex)
    }

    // MARK: - Exercise detail

    func openExercise(_ ex: Exercise) {
        selectedExerciseId = ex.id
        showExerciseDetail = true
    }

    func selectedExercise() -> Exercise? {
        guard let day = selectedDay else { return nil }
        guard let id = selectedExerciseId else { return nil }
        return day.exercises.first(where: { $0.id == id })
    }

    func savePhotoForSelectedExercise(_ data: Data?) {
        guard let dayId = selectedDayId else { return }
        guard let exId = selectedExerciseId else { return }

        guard let dayIndex = days.firstIndex(where: { $0.id == dayId }) else { return }
        guard let exIndex = days[dayIndex].exercises.firstIndex(where: { $0.id == exId }) else { return }

        days[dayIndex].exercises[exIndex].photoData = data
    }
}
