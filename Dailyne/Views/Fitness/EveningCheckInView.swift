//
//  EveningCheckInView.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 23/01/2026.
//

import SwiftUI

struct EveningCheckInView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var fitnessStore: FitnessStore

    @State private var stepsText: String = ""
    @State private var waterText: String = ""
    @State private var sleepText: String = ""
    @State private var hadActivity: Bool = false

    private var stepsValue: Int { Int(stepsText) ?? 0 }
    private var waterValue: Double { Double(waterText.replacingOccurrences(of: ",", with: ".")) ?? 0 }
    private var sleepValue: Double { Double(sleepText.replacingOccurrences(of: ",", with: ".")) ?? 0 }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.98, green: 0.94, blue: 0.95)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 14) {

                    Text("Evening Check-In ✨")
                        .font(.system(size: 28, weight: .semibold))

                    Text("Let’s quickly track today so your habits update automatically 💗")
                        .foregroundStyle(.secondary)

                    // Steps
                    CheckRow(
                        title: "Steps",
                        subtitle: "Goal: \(fitnessStore.stepsGoal) steps",
                        placeholder: "e.g. 7420",
                        text: $stepsText,
                        keyboard: .numberPad
                    )

                    // Water
                    CheckRow(
                        title: "Water (liters)",
                        subtitle: "Goal: \(String(format: "%.1f", fitnessStore.waterGoalLiters)) L",
                        placeholder: "e.g. 1.2",
                        text: $waterText,
                        keyboard: .decimalPad
                    )

                    // Sleep
                    CheckRow(
                        title: "Sleep (hours)",
                        subtitle: "Goal: \(String(format: "%.0f", fitnessStore.sleepGoalHours)) hours",
                        placeholder: "e.g. 7.5",
                        text: $sleepText,
                        keyboard: .decimalPad
                    )

                    // Activity
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Activity")
                            .font(.system(size: 16, weight: .semibold))

                        Toggle("Did you have any movement / workout today?", isOn: $hadActivity)
                            .tint(Color(red: 0.86, green: 0.36, blue: 0.45))
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                    Spacer()

                    Button {
                        fitnessStore.submitCheckIn(
                            steps: stepsValue,
                            waterLiters: waterValue,
                            sleepHours: sleepValue,
                            hadActivity: hadActivity
                        )
                        dismiss()
                    } label: {
                        Text("Save")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(red: 0.86, green: 0.36, blue: 0.45).opacity(0.18))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .foregroundStyle(Color.black.opacity(0.85))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .navigationTitle("Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

private struct CheckRow: View {
    let title: String
    let subtitle: String
    let placeholder: String
    @Binding var text: String
    let keyboard: UIKeyboardType

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .textFieldStyle(.roundedBorder)
        }
        .padding(14)
        .background(Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    EveningCheckInView()
        .environmentObject(FitnessStore())
}
