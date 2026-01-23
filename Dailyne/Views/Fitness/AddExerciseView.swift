//
//  AddExerciseView.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 23/01/2026.
//

import SwiftUI

struct AddExerciseView: View {

    @Environment(\.dismiss) private var dismiss
    let onPick: (String) -> Void

    @State private var search: String = ""

    // ✅ tvoje vlastné cviky natrvalo
    @AppStorage("customExercisesCSV") private var customExercisesCSV: String = ""

    private let builtInExercises: [String] = [
        "Squat", "Hip Thrust", "Deadlift", "Leg Press",
        "Lat Pulldown", "Seated Row", "Bench Press",
        "Shoulder Press", "Bicep Curl", "Tricep Pushdown",
        "RDL", "Bulgarian Split Squat", "Calf Raises"
    ]

    private var customExercises: [String] {
        let parts = customExercisesCSV
            .split(separator: "|")
            .map { String($0) }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return Array(Set(parts)).sorted()
    }

    private var allExercises: [String] {
        let all = builtInExercises + customExercises
        return Array(Set(all)).sorted()
    }

    private var trimmedSearch: String {
        search.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var filtered: [String] {
        if trimmedSearch.isEmpty { return allExercises }
        return allExercises.filter { $0.lowercased().contains(trimmedSearch.lowercased()) }
    }

    private var searchIsNewExercise: Bool {
        let t = trimmedSearch
        if t.isEmpty { return false }
        return !allExercises.contains(where: { $0.lowercased() == t.lowercased() })
    }

    var body: some View {
        NavigationStack {
            List {

                Section {
                    TextField("Search exercise…", text: $search)
                }

                if searchIsNewExercise {
                    Section {
                        Button {
                            addCustomExerciseAndPick(trimmedSearch)
                        } label: {
                            Text("+ Add \"\(trimmedSearch)\"")
                                .font(.system(size: 15, weight: .semibold))
                        }
                    }
                }

                Section("Exercises") {
                    ForEach(filtered, id: \.self) { name in
                        Button {
                            onPick(name)
                            dismiss()
                        } label: {
                            Text(name)
                        }
                    }
                }
            }
            .navigationTitle("Add exercise")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func addCustomExerciseAndPick(_ name: String) {
        saveCustomExercise(name)
        onPick(name)
        dismiss()
    }

    private func saveCustomExercise(_ name: String) {
        let clean = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if clean.isEmpty { return }

        var list = customExercises
        if !list.contains(where: { $0.lowercased() == clean.lowercased() }) {
            list.append(clean)
        }

        customExercisesCSV = list.joined(separator: "|")
    }
}
