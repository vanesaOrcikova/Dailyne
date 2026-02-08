//
//  WorkoutPlanStore.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 23/01/2026.
//

import Foundation
import UIKit
import Combine

final class WorkoutPlanStore: ObservableObject {

    @Published var days: [WorkoutDay] = [] {
        didSet { saveToDisk() }
    }

    @Published var selectedDayId: UUID?
    @Published var selectedExerciseId: UUID?

    @Published var showAddExercise: Bool = false
    @Published var showExerciseDetail: Bool = false

    init() {
        loadFromDisk()

        if days.isEmpty {
            days = [
                WorkoutDay(
                    title: "Day 1",
                    exercises: [
                        WorkoutExercise(name: "Squat"),
                        WorkoutExercise(name: "Hip Thrust"),
                        WorkoutExercise(name: "Lat Pulldown")
                    ]
                )
            ]
        }

        selectedDayId = days.first?.id
    }

    // MARK: - Selected day

    var selectedDay: WorkoutDay? {
        guard let id = selectedDayId else { return nil }
        return days.first(where: { $0.id == id })
    }

    // MARK: - Paths

    private var appDir: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private var storeURL: URL {
        appDir.appendingPathComponent("workout_store.json")
    }

    private var photosDir: URL {
        let p = appDir.appendingPathComponent("ExercisePhotos", isDirectory: true)
        try? FileManager.default.createDirectory(at: p, withIntermediateDirectories: true)
        return p
    }

    // MARK: - Save / Load

    private func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(days)
            try data.write(to: storeURL, options: [.atomic])
        } catch {
            print("❌ Save failed:", error)
        }
    }

    private func loadFromDisk() {
        guard FileManager.default.fileExists(atPath: storeURL.path) else { return }
        do {
            let data = try Data(contentsOf: storeURL)
            days = try JSONDecoder().decode([WorkoutDay].self, from: data)
        } catch {
            print("❌ Load failed:", error)
        }
    }

    // MARK: - Day actions

    func addDayAndReturnId() -> UUID {
        let new = WorkoutDay(title: "New")
        days.append(new)
        selectedDayId = new.id
        return new.id
    }

    func deleteDay(_ day: WorkoutDay) {
        days.removeAll { $0.id == day.id }
        if selectedDayId == day.id {
            selectedDayId = days.first?.id
        }
    }

    func renameDay(id: UUID, to newTitle: String) {
        if let i = days.firstIndex(where: { $0.id == id }) {
            days[i].title = newTitle
        }
    }

    // MARK: - Exercise actions

    func addExercise(name: String) {
        guard let dId = selectedDayId else { return }
        guard let dIndex = days.firstIndex(where: { $0.id == dId }) else { return }

        let ex = WorkoutExercise(name: name)
        days[dIndex].exercises.append(ex)
    }

    func openExercise(_ ex: WorkoutExercise) {
        selectedExerciseId = ex.id
        showExerciseDetail = true
    }

    func selectedExercise() -> WorkoutExercise? {
        guard let dId = selectedDayId,
              let eId = selectedExerciseId,
              let dIndex = days.firstIndex(where: { $0.id == dId }) else { return nil }

        return days[dIndex].exercises.first(where: { $0.id == eId })
    }

    private func updateExercise(_ exId: UUID, in dayId: UUID, _ update: (inout WorkoutExercise) -> Void) {
        guard let dIndex = days.firstIndex(where: { $0.id == dayId }) else { return }
        guard let eIndex = days[dIndex].exercises.firstIndex(where: { $0.id == exId }) else { return }
        update(&days[dIndex].exercises[eIndex])
    }

    // MARK: - Notes

    func saveNotesForSelectedExercise(_ text: String) {
        guard let dId = selectedDayId, let eId = selectedExerciseId else { return }
        updateExercise(eId, in: dId) { ex in
            ex.notes = text
        }
    }

    // MARK: - Sets

    func addSetToSelectedExercise() {
        guard let dId = selectedDayId, let eId = selectedExerciseId else { return }
        updateExercise(eId, in: dId) { ex in
            ex.sets.append(WorkoutSet(weight: "", reps: ""))
        }
    }

    func updateSet(for exerciseId: UUID, setId: UUID, weight: String, reps: String) {
        guard let dId = selectedDayId else { return }
        updateExercise(exerciseId, in: dId) { ex in
            if let i = ex.sets.firstIndex(where: { $0.id == setId }) {
                ex.sets[i].weight = weight
                ex.sets[i].reps = reps
            }
        }
    }

    func deleteSet(for exerciseId: UUID, setId: UUID) {
        guard let dId = selectedDayId else { return }
        updateExercise(exerciseId, in: dId) { ex in
            ex.sets.removeAll { $0.id == setId }
        }
    }

    // MARK: - Photos

    func savePhotoForSelectedExercise(_ data: Data) {
        guard let dId = selectedDayId, let eId = selectedExerciseId else { return }

        let filename = "exercise_\(eId.uuidString).jpg"
        let url = photosDir.appendingPathComponent(filename)

        do {
            try data.write(to: url, options: [.atomic])
            updateExercise(eId, in: dId) { ex in
                ex.photoFilename = filename
            }
        } catch {
            print("❌ Photo save failed:", error)
        }
    }

    func loadPhoto(for ex: WorkoutExercise) -> UIImage? {
        guard let name = ex.photoFilename else { return nil }
        let url = photosDir.appendingPathComponent(name)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}

