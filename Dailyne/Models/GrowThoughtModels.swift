//
//  GrowThoughtModels.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 28/01/2026.
//

import Foundation

enum PlantNeed: String, Codable, CaseIterable {
    case water
    case sun
    case weeds
    case none
}

enum PlantStage: Int, Codable, CaseIterable {
    case seed = 0
    case sprout
    case small
    case leafy
    case bloom
}

enum FlowerType: String, Codable, CaseIterable, Identifiable {
    case daisy, tulip, rose, lavender, sunflower, cactus
    var id: String { rawValue }

    var title: String {
        switch self {
        case .daisy: return "Daisy"
        case .tulip: return "Tulip"
        case .rose: return "Rose"
        case .lavender: return "Lavender"
        case .sunflower: return "Sunflower"
        case .cactus: return "Cactus"
        }
    }

    var emoji: String {
        switch self {
        case .daisy: return "🌼"
        case .tulip: return "🌷"
        case .rose: return "🌹"
        case .lavender: return "🪻"
        case .sunflower: return "🌻"
        case .cactus: return "🌵"
        }
    }
}

struct GrowThoughtState: Codable {
    var dayKey: String

    // onboarding
    var flower: FlowerType?
    var intention: String

    // progress
    var points: Int
    var stage: PlantStage

    // daily actions
    var didWater: Bool
    var didSun: Bool
    var didWeeds: Bool

    // daily notes
    var waterNote: String
    var weedsNote: String

    // daily traits (text after action)
    var waterTrait: String
    var sunTrait: String
    var weedsTrait: String

    // UI hint
    var todayNeed: PlantNeed

    // ✅ NEW: weeds appear only sometimes
    var weedsAppearToday: Bool
}
