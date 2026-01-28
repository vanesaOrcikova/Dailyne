//
//  GrowThoughtStore.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 28/01/2026.
//

import Foundation
import Combine

final class GrowThoughtStore: ObservableObject {

    @Published var state: GrowThoughtState {
        didSet { save() }
    }

    private let storageKey = "grow_thought_state_v1"

    init() {
        let today = Self.dayKey(Date())

        if let loaded = Self.load(storageKey: storageKey) {
            // ak je nový deň -> reset denné veci, ale nechaj intention/progress
            if loaded.dayKey != today {
                state = Self.resetForNewDay(from: loaded, todayKey: today)
            } else {
                state = loaded
            }
        } else {
            // prvýkrát
            state = GrowThoughtState(
                dayKey: today,
                intention: "Peace",
                points: 0,
                stage: .seed,
                didWater: false,
                didSun: false,
                didWeeds: false,
                waterNote: "",
                weedsNote: "",
                todayNeed: .water
            )
            save()
        }
    }

    // MARK: - Public API

    func ensureToday() {
        let today = Self.dayKey(Date())
        if state.dayKey != today {
            state = Self.resetForNewDay(from: state, todayKey: today)
        }
    }

    func setIntention(_ text: String) {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        state.intention = t
    }

    func water(note: String) {
        guard !state.didWater else { return }
        state.didWater = true
        state.waterNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        addPoints(2)
        refreshNeed()
    }

    func sun() {
        guard !state.didSun else { return }
        state.didSun = true
        addPoints(1)
        refreshNeed()
    }

    func weeds(note: String) {
        guard !state.didWeeds else { return }
        state.didWeeds = true
        state.weedsNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        addPoints(2)
        refreshNeed()
    }

    func completionText() -> String {
        let done = [state.didWater, state.didSun, state.didWeeds].filter { $0 }.count
        if done == 0 { return "Just a tiny step today." }
        if done == 1 { return "Nice. Keep it gentle." }
        if done == 2 { return "You’re taking care of you." }
        return "Your plant feels loved ✨"
    }

    // MARK: - Internals

    private func addPoints(_ p: Int) {
        state.points += p
        state.stage = Self.stage(for: state.points)
    }

    private func refreshNeed() {
        // jednoduchá logika: čo ešte chýba dnes
        if !state.didWater { state.todayNeed = .water; return }
        if !state.didSun { state.todayNeed = .sun; return }
        if !state.didWeeds { state.todayNeed = .weeds; return }
        state.todayNeed = .none
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(state)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("❌ GrowThought save failed:", error)
        }
    }

    private static func load(storageKey: String) -> GrowThoughtState? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(GrowThoughtState.self, from: data)
    }

    // MARK: - Daily reset

    private static func resetForNewDay(from old: GrowThoughtState, todayKey: String) -> GrowThoughtState {
        var s = old
        s.dayKey = todayKey
        s.didWater = false
        s.didSun = false
        s.didWeeds = false
        s.waterNote = ""
        s.weedsNote = ""
        // každý deň môže začať inou potrebou (aby to bolo živé)
        let needs: [PlantNeed] = [.water, .sun, .weeds]
        s.todayNeed = needs.randomElement() ?? .water
        return s
    }

    private static func stage(for points: Int) -> PlantStage {
        switch points {
        case 0...2: return .seed
        case 3...6: return .sprout
        case 7...12: return .small
        case 13...20: return .leafy
        default: return .bloom
        }
    }

    static func dayKey(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.calendar = Calendar.current
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}
