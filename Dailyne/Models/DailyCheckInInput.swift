//
//  DailyCheckInInput.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 23/01/2026.
//

import Foundation

struct DailyCheckInInput: Codable {
    var dateKey: String
    var steps: Int
    var waterLiters: Double
    var sleepHours: Double
    var hadActivity: Bool
}
