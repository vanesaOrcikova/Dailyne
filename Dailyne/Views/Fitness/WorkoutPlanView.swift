//
//  WorkoutPlanView.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 23/01/2026.
//

import SwiftUI

struct WorkoutPlanView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = WorkoutPlanStore()

    // rename/add kategórie
    @State private var showNameSheet: Bool = false
    @State private var nameText: String = ""
    @State private var renamingDayId: UUID? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.98, green: 0.94, blue: 0.95)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {

                        Text("Workout Plan")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(0.85))

                        // ✅ tabs
                        WorkoutDayTabsView(
                            days: store.days,
                            selectedId: $store.selectedDayId,
                            onAddDay: {
                                let newId = store.addDayAndReturnId()
                                renamingDayId = newId
                                nameText = ""
                                showNameSheet = true
                            },
                            onRenameDay: { day in
                                renamingDayId = day.id
                                nameText = day.title
                                showNameSheet = true
                            },
                            onDeleteDay: { day in
                                store.deleteDay(day)
                            },
                            onSelectDay: { day in
                                store.selectedDayId = day.id
                            }
                        )

                        // ✅ Exercises list
                        SoftCard {
                            VStack(alignment: .leading, spacing: 10) {

                                if let day = store.selectedDay {

                                    if day.exercises.isEmpty {
                                        Text("No exercises yet ✨")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(Color.black.opacity(0.45))
                                            .padding(.vertical, 6)
                                    }

                                    ForEach(day.exercises) { ex in
                                        Button {
                                            store.openExercise(ex)
                                        } label: {
                                            HStack(spacing: 10) {

                                                // ✅ bodka
                                                Circle()
                                                    .frame(width: 6, height: 6)
                                                    .foregroundStyle(Color.black.opacity(0.35))

                                                Text(ex.name)
                                                    .font(.system(size: 15, weight: .semibold))
                                                    .foregroundStyle(Color.black.opacity(0.8))

                                                Spacer()

                                                // ✅ indikátor že má fotku
                                                if ex.photoData != nil {
                                                    Image(systemName: "photo")
                                                        .font(.system(size: 13, weight: .semibold))
                                                        .foregroundStyle(Color.black.opacity(0.35))
                                                }
                                            }
                                            .padding(.vertical, 6)
                                        }
                                        .buttonStyle(.plain)
                                    }

                                    Button {
                                        store.showAddExercise = true
                                    } label: {
                                        HStack {
                                            Text("+ Add exercise")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundStyle(Color.black.opacity(0.6))
                                            Spacer()
                                        }
                                        .padding(.top, 6)
                                    }
                                    .buttonStyle(.plain)

                                } else {
                                    Text("Tap + to add a category ✨")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }

            // ✅ Add exercise sheet
            .sheet(isPresented: $store.showAddExercise) {
                AddExerciseView(
                    onPick: { name in
                        store.addExercise(name: name)
                    }
                )
                .presentationDetents([.medium])
            }

            // ✅ Exercise detail sheet (photo)
            .sheet(isPresented: $store.showExerciseDetail) {
                ExerciseLogSheetView(store: store)
                    .presentationDetents([.medium, .large])
            }

            // ✅ Rename/Add category sheet
            .sheet(isPresented: $showNameSheet) {
                NavigationStack {
                    VStack(alignment: .leading, spacing: 14) {

                        Text("Category name")
                            .font(.system(size: 16, weight: .semibold))

                        TextField("e.g. Glutes / Back / Day 1", text: $nameText)
                            .textFieldStyle(.roundedBorder)

                        Button {
                            if let id = renamingDayId {
                                let finalName = nameText.trimmingCharacters(in: .whitespacesAndNewlines)
                                store.renameDay(id: id, to: finalName.isEmpty ? "New" : finalName)
                                store.selectedDayId = id
                            }
                            showNameSheet = false
                        } label: {
                            Text("Save")
                                .font(.system(size: 15, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.black.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)

                        Spacer()
                    }
                    .padding(20)
                    .navigationTitle("Edit category")
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Close") { showNameSheet = false }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
}
