//
//  FitnessView.swift
//  SoftLifePlanner
//
//  Created by Vanesa Orcikova on 28/12/2025.
//

import SwiftUI

struct FitnessView: View {
    var body: some View {
        NavigationStack {
            FitnessDashboardView()
                .navigationTitle("Fitness")
        }
    }
}

#Preview {
    FitnessView()
        .environmentObject(FitnessStore())
}
