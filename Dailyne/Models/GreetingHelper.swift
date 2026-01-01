//
//  GreetingHelper.swift
//  SoftLifePlanner
//
//  Created by Vanesa Orcikova on 28/12/2025.
//

import Foundation

enum GreetingHelper {

    static func greeting(for date: Date = Date()) -> String {
        let hour = Calendar.current.component(.hour, from: date)

        if hour >= 5 && hour < 12 {
            return "morning"
        } else if hour >= 12 && hour < 18 {
            return "afternoon"
        } else {
            return "evening"
        }
    }
}

