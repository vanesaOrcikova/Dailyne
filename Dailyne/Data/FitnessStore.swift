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

    // MARK: - Thresholds (motivácia)
    let stepsGoal: Int = 7000
    let waterGoalLiters: Double = 1.0
    let sleepGoalHours: Double = 7.0

    // MARK: - Weekly (MVP)
    @AppStorage("fitnessWeeklyGoal") private var weeklyGoalStorage: Int = 5
    @AppStorage("fitnessCompletedThisWeek") private var completedStorage: Int = 2
    @AppStorage("fitnessWorkoutDaysCSV") private var workoutDaysCSV: String = ""

    // MARK: - Habits daily
    @AppStorage("fitnessHabitsDateKey") private var habitsDateKey: String = ""
    @AppStorage("habitWalk") private var habitWalkStorage: Bool = false
    @AppStorage("habitWater") private var habitWaterStorage: Bool = false
    @AppStorage("habitSleep") private var habitSleepStorage: Bool = false
    @AppStorage("habitStretch") private var habitStretchStorage: Bool = false

    // MARK: - Heart (Weekly feelings)
    @AppStorage("fitnessFeelingWeekData") private var feelingWeekData: Data = Data()

    @Published var bodyFeelingRating: Int = 0 {
        didSet { saveTodayFeeling() }
    }

    /// key: "yyyy-MM-dd", value: 0...5
    @Published var weekFeeling: [String: Int] = [:]

    // MARK: - Last check-in stored
    @AppStorage("fitnessLastCheckInData") private var lastCheckInData: Data = Data()

    @Published var quote: String = "You don’t need motivation, you need consistency."

    // Published proxy hodnoty
    @Published var weeklyGoal: Int = 5 { didSet { weeklyGoalStorage = weeklyGoal } }
    @Published var completedThisWeek: Int = 2 { didSet { completedStorage = completedThisWeek } }
    @Published var workoutDaysThisWeek: Set<Weekday> = [] { didSet { saveWorkoutDays() } }

    @Published var habitWalk: Bool = false { didSet { habitWalkStorage = habitWalk } }
    @Published var habitWater: Bool = false { didSet { habitWaterStorage = habitWater } }
    @Published var habitSleep: Bool = false { didSet { habitSleepStorage = habitSleep } }
    @Published var habitStretch: Bool = false { didSet { habitStretchStorage = habitStretch } } // teraz = “activity”

    // Check-in UI helper
    @Published var shouldShowEveningCheckIn: Bool = false

    init() {
        weeklyGoal = weeklyGoalStorage
        completedThisWeek = completedStorage
        workoutDaysThisWeek = loadWorkoutDays()

        resetHabitsIfNeeded()

        habitWalk = habitWalkStorage
        habitWater = habitWaterStorage
        habitSleep = habitSleepStorage
        habitStretch = habitStretchStorage

        updateShouldShowEveningCheckIn()

        loadFeelingWeek()
        loadTodayFeeling()
    }

    // MARK: - Evening check-in

    func updateShouldShowEveningCheckIn() {
        resetHabitsIfNeeded()

        let now = Date()
        let hour = Calendar.current.component(.hour, from: now)

        // chceme aby sa zobrazil večer (napr. od 19:00)
        guard hour >= 19 else {
            shouldShowEveningCheckIn = false
            return
        }

        // ak už bol check-in dnes, nezobrazuj
        let today = todayKey()
        let last = lastCheckIn()?.dateKey

        shouldShowEveningCheckIn = (last != today)
    }

    func submitCheckIn(steps: Int, waterLiters: Double, sleepHours: Double, hadActivity: Bool) {
        // vyhodnotenie habits
        habitWalk = steps >= stepsGoal
        habitWater = waterLiters >= waterGoalLiters
        habitSleep = sleepHours >= sleepGoalHours
        habitStretch = hadActivity

        // uloženie checkinu
        let input = DailyCheckInInput(
            dateKey: todayKey(),
            steps: steps,
            waterLiters: waterLiters,
            sleepHours: sleepHours,
            hadActivity: hadActivity
        )

        do {
            lastCheckInData = try JSONEncoder().encode(input)
        } catch {
            // ticho
        }

        shouldShowEveningCheckIn = false
        habitsDateKey = todayKey()
    }

    func lastCheckIn() -> DailyCheckInInput? {
        guard !lastCheckInData.isEmpty else { return nil }
        return try? JSONDecoder().decode(DailyCheckInInput.self, from: lastCheckInData)
    }

    // MARK: - Weekly goal interactions

    func increaseWeeklyGoal() { weeklyGoal = min(14, weeklyGoal + 1) }
    func decreaseWeeklyGoal() { weeklyGoal = max(1, weeklyGoal - 1) }

    func toggleWorkoutDay(_ day: Weekday) {
        if workoutDaysThisWeek.contains(day) {
            workoutDaysThisWeek.remove(day)
        } else {
            workoutDaysThisWeek.insert(day)
        }
    }

    // MARK: - Habits interactions (manual toggle from dashboard)

    func toggleHabit(_ habit: FitnessHabit) {
        resetHabitsIfNeeded()

        switch habit {
        case .walk:
            habitWalk.toggle()
        case .water:
            habitWater.toggle()
        case .sleep:
            habitSleep.toggle()
        case .activity:
            habitStretch.toggle()
        }
    }

    // MARK: - Habits reset

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

    // MARK: - Date key helper (stable)

    /// Stable date key: "yyyy-MM-dd"
    private func todayKey(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "sk_SK")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
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
            if let d = Weekday(rawValue: p) {
                set.insert(d)
            }
        }

        return set
    }

    // MARK: - Feeling week persistence

    /// uloží rating pre dnešok do weekFeeling
    private func saveTodayFeeling() {
        let key = todayKey()
        weekFeeling[key] = bodyFeelingRating
        saveFeelingWeek()
    }

    /// načítaj uložený týždeň
    private func loadFeelingWeek() {
        guard !feelingWeekData.isEmpty,
              let decoded = try? JSONDecoder().decode([String: Int].self, from: feelingWeekData)
        else {
            weekFeeling = [:]
            return
        }
        weekFeeling = decoded
    }

    /// načítaj dnešný rating, ak existuje
    private func loadTodayFeeling() {
        let key = todayKey()
        bodyFeelingRating = weekFeeling[key] ?? 0
    }

    /// uloženie do AppStorage
    private func saveFeelingWeek() {
        if let data = try? JSONEncoder().encode(weekFeeling) {
            feelingWeekData = data
        }
    }

    /// vráti ratingy pre aktuálny týždeň (Mon–Sun)
    func feelingForCurrentWeek() -> [Int] {
        let calendar = Calendar.current
        let now = Date()

        // začiatok týždňa
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now

        var result: [Int] = []
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) ?? now
            let key = todayKey(date)
            result.append(weekFeeling[key] ?? 0)
        }
        return result
    }
}

// MARK: - FitnessHabit (for toggles in dashboard)

enum FitnessHabit {
    case walk
    case water
    case sleep
    case activity
}
