//
//  FitnessView.swift
//  SoftLifePlanner
//
//  Created by Vanesa Orcikova on 28/12/2025.
//

import SwiftUI

struct FitnessView: View {

    @EnvironmentObject var fitnessStore: FitnessStore
    @State private var selectedDayIndex: Int? = nil

    var body: some View {
        NavigationStack {
            FitnessDashboardView(fitnessStore: fitnessStore)
                .navigationTitle("Fitness")
        }
        .onAppear {
            fitnessStore.updateShouldShowEveningCheckIn()
        }
        .sheet(isPresented: $fitnessStore.shouldShowEveningCheckIn) {
            EveningCheckInView()
                .environmentObject(fitnessStore)
                .presentationDetents([.large])
        }
    }
}

#Preview {
    FitnessView()
        .environmentObject(FitnessStore())
}
