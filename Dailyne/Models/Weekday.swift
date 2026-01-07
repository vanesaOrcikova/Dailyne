//
//  Weekday.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 07/01/2026.
//

import Foundation

enum Weekday: Int, CaseIterable, Identifiable {
    case mon = 1, tue, wed, thu, fri, sat, sun
    
    var id: Int { rawValue }
    
    var short: String {
        switch self {
            case .mon: return "M"
            case .tue: return "T"
            case .wed: return "W"
            case .thu: return "T"
            case .fri: return "F"
            case .sat: return "S"
            case .sun: return "S"
        }
    }
    
}

