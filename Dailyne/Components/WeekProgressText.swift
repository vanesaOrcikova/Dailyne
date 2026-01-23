//
//  WeekProgressText.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 23/01/2026.
//

import SwiftUI

struct WeekProgressText: View {
    let completed: Int
    let total: Int = 7

    var body: some View {
        Text("\(completed) / \(total) completed")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}
