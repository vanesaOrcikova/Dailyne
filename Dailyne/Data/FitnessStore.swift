//
//  FitnessStore.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 07/01/2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class FitnessStore: ObservableObject {

    @AppStorage("fitnessWeeklyGoal") private var weeklyGoalStorage: Int = 5
    @AppStorage("fitnessCompletedThisWeek") private var completedStorage: Int = 2

    // uložíme ako text "1,2,3" (dni v týždni)
    @AppStorage("fitnessWorkoutDaysCSV") private var workoutDaysCSV: String = ""

    // Habits daily (ukladáme aj dátum posledného resetu)
    @AppStorage("fitnessHabitsDateKey") private var habitsDateKey: String = ""
    @AppStorage("habitWalk") private var habitWalkStorage: Bool = false
    @AppStorage("habitWater") private var habitWaterStorage: Bool = false
    @AppStorage("habitSleep") private var habitSleepStorage: Bool = false
    @AppStorage("habitStretch") private var habitStretchStorage: Bool = false

    @Published var quote: String = "You don’t need motivation, you need consistency."

    // Published proxy hodnoty (aby UI reagovalo)
    @Published var weeklyGoal: Int = 5 { didSet { weeklyGoalStorage = weeklyGoal } }
    @Published var completedThisWeek: Int = 2 { didSet { completedStorage = completedThisWeek } }
    @Published var workoutDaysThisWeek: Set<Weekday> = [] { didSet { saveWorkoutDays() } }

    @Published var habitWalk: Bool = false { didSet { habitWalkStorage = habitWalk } }
    @Published var habitWater: Bool = false { didSet { habitWaterStorage = habitWater } }
    @Published var habitSleep: Bool = false { didSet { habitSleepStorage = habitSleep } }
    @Published var habitStretch: Bool = false { didSet { habitStretchStorage = habitStretch } }

    init() {
        weeklyGoal = weeklyGoalStorage
        completedThisWeek = completedStorage
        workoutDaysThisWeek = loadWorkoutDays()

        // daily habits reset
        resetHabitsIfNeeded()

        habitWalk = habitWalkStorage
        habitWater = habitWaterStorage
        habitSleep = habitSleepStorage
        habitStretch = habitStretchStorage
    }

    // MARK: - Weekly goal interactions

    func increaseWeeklyGoal() {
        weeklyGoal = min(14, weeklyGoal + 1)
    }

    func decreaseWeeklyGoal() {
        weeklyGoal = max(1, weeklyGoal - 1)
    }

    func toggleWorkoutDay(_ day: Weekday) {
        if workoutDaysThisWeek.contains(day) {
            workoutDaysThisWeek.remove(day)
        } else {
            workoutDaysThisWeek.insert(day)
        }
    }

    // MARK: - Habits interactions

    func toggleHabit(_ habit: FitnessHabit) {
        resetHabitsIfNeeded()
        switch habit {
        case .walk: habitWalk.toggle()
        case .water: habitWater.toggle()
        case .sleep: habitSleep.toggle()
        case .stretch: habitStretch.toggle()
        }
    }

    func resetHabitsNow() {
        habitWalk = false
        habitWater = false
        habitSleep = false
        habitStretch = false
        habitsDateKey = todayKey()
    }

    private func resetHabitsIfNeeded() {
        let key = todayKey()
        if habitsDateKey != key {
            habitWalkStorage = false
            habitWaterStorage = false
            habitSleepStorage = false
            habitStretchStorage = false
            habitsDateKey = key
        }
    }

    private func todayKey() -> String {
        let c = Calendar.current
        let d = Date()
        let y = c.component(.year, from: d)
        let m = c.component(.month, from: d)
        let day = c.component(.day, from: d)
        return "\(y)-\(m)-\(day)"
    }

    // MARK: - Workout days persistence

    private func saveWorkoutDays() {
        let values = workoutDaysThisWeek.map { String($0.rawValue) }.sorted()
        workoutDaysCSV = values.joined(separator: ",")
    }

    private func loadWorkoutDays() -> Set<Weekday> {
        if workoutDaysCSV.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return [] }
        let parts = workoutDaysCSV.split(separator: ",").map { Int($0) ?? 0 }
        var set: Set<Weekday> = []
        for p in parts {
            if let d = Weekday(rawValue: p) { set.insert(d) }
        }
        return set
    }
}

enum FitnessHabit: CaseIterable, Identifiable {
    case walk, water, sleep, stretch

    var id: String { title }

    var title: String {
        switch self {
        case .walk: return "Walk"
        case .water: return "Water"
        case .sleep: return "Sleep"
        case .stretch: return "Stretch"
        }
    }

    var emoji: String {
        switch self {
        case .walk: return "🚶"
        case .water: return "💧"
        case .sleep: return "😴"
        case .stretch: return "🧘"
        }
    }
}


