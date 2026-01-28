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

struct GrowThoughtState: Codable {
    // deň (aby sa to resetovalo každý deň)
    var dayKey: String

    // čo pestujem
    var intention: String // napr. "Confidence", "Peace", "Discipline"

    // progres
    var points: Int
    var stage: PlantStage

    // dnešné akcie
    var didWater: Bool
    var didSun: Bool
    var didWeeds: Bool

    // dnešné mini zápisky
    var waterNote: String
    var weedsNote: String

    // posledná potreba (čo sa má ukazovať na karte)
    var todayNeed: PlantNeed
}
