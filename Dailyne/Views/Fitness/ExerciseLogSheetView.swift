//
//  ExerciseLogSheetView.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 26/01/2026.
//

import SwiftUI
import PhotosUI
import UIKit

struct ExerciseLogSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: WorkoutPlanStore

    @State private var notesText: String = ""
    @State private var pickerItem: PhotosPickerItem? = nil

    var body: some View {
        let ex = store.selectedExercise()

        ZStack {
            // girly background
            Color(red: 0.98, green: 0.94, blue: 0.95)
                .ignoresSafeArea()

            VStack(spacing: 10) {

                // ✅ namiesto Capsule (grabberu) len odsadenie, aby to nešlo úplne hore
                Spacer().frame(height: 10)

                // header
                HStack(alignment: .center) {
                    Text(ex?.name ?? "Exercise")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.85))

                    Spacer()

                    Button("Close") { dismiss() }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.55))
                }
                .padding(.horizontal, 20)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {

                        // PHOTO
                        SoftCard {
                            VStack(alignment: .leading, spacing: 8) {
                                sectionTitle("Photo")

                                PhotosPicker(selection: $pickerItem, matching: .images) {
                                    if let ex = ex,
                                       let img = store.loadPhoto(for: ex) {

                                        let isPortrait = img.size.height > img.size.width

                                        if isPortrait {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 18)
                                                    .fill(Color.white.opacity(0.35))

                                                Image(uiImage: img)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .padding(10)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 300)
                                            .clipShape(RoundedRectangle(cornerRadius: 18))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 18)
                                                    .stroke(Color.black.opacity(0.04), lineWidth: 1)
                                            )

                                        } else {
                                            Image(uiImage: img)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 220)
                                                .clipped()
                                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 18)
                                                        .stroke(Color.black.opacity(0.04), lineWidth: 1)
                                                )
                                        }

                                    } else {
                                        VStack(spacing: 6) {
                                            Image(systemName: "photo")
                                                .font(.system(size: 20, weight: .semibold))
                                                .foregroundStyle(Color.black.opacity(0.22))

                                            Text("Tap to add a photo")
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundStyle(Color.black.opacity(0.45))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 170)
                                        .background(Color.white.opacity(0.55))
                                        .clipShape(RoundedRectangle(cornerRadius: 18))
                                    }
                                }
                                .buttonStyle(.plain)
                                .onChange(of: pickerItem) { item in
                                    guard let item else { return }
                                    Task {
                                        if let data = try? await item.loadTransferable(type: Data.self) {
                                            await MainActor.run {
                                                store.savePhotoForSelectedExercise(data)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // SETS
                        SoftCard {
                            VStack(alignment: .leading, spacing: 8) {
                                sectionTitle("Sets")

                                HStack {
                                    Text("Set").frame(width: 38, alignment: .leading)
                                    Text("Weight").frame(maxWidth: .infinity, alignment: .leading)
                                    Text("Reps").frame(width: 64, alignment: .leading)
                                }
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.black.opacity(0.45))

                                Divider().opacity(0.18)

                                if let ex = ex {
                                    ForEach(Array(ex.sets.enumerated()), id: \.element.id) { index, s in
                                        CompactSetRow(
                                            setNumber: index + 1,
                                            weight: s.weight,
                                            reps: s.reps,
                                            onChange: { w, r in
                                                store.updateSet(for: ex.id, setId: s.id, weight: w, reps: r)
                                            },
                                            onDelete: {
                                                store.deleteSet(for: ex.id, setId: s.id)
                                            }
                                        )
                                    }
                                }

                                Button {
                                    store.addSetToSelectedExercise()
                                } label: {
                                    HStack {
                                        Text("+ Add set")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(Color.black.opacity(0.55))
                                        Spacer()
                                    }
                                    .padding(.top, 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        // NOTES
                        SoftCard {
                            VStack(alignment: .leading, spacing: 8) {
                                sectionTitle("Notes")

                                ZStack(alignment: .topLeading) {

                                    // ✅ placeholder zarovnaný s reálnym textom v TextEditor
                                    if notesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        Text("Felt strong today…")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(Color.black.opacity(0.30))
                                            .padding(.top, 16)     // ✅ viac ako 10, aby sedelo s TextEditorom
                                            .padding(.leading, 6)  // ✅ sedí s default insetom TextEditor
                                    }

                                    TextEditor(text: $notesText)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(Color.black.opacity(0.75))
                                        .scrollContentBackground(.hidden)
                                        .padding(.horizontal, 2)  // ✅ jemná korekcia, aby text nebol nalepený
                                        .padding(.vertical, 8)
                                }
                                .frame(height: 70)
                                .background(Color.white.opacity(0.55))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }

                        // SAVE BUTTON
                        Button {
                            store.saveNotesForSelectedExercise(notesText)
                            dismiss()
                        } label: {
                            Text("Save Exercise")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.black.opacity(0.85))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(Color.white.opacity(0.75))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(Color.black.opacity(0.06), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)

                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                }
            }
        }
        .onAppear {
            notesText = ex?.notes ?? ""
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.black.opacity(0.55))
    }
}

private struct CompactSetRow: View {
    let setNumber: Int

    @State private var weightText: String
    @State private var repsText: String

    let onChange: (String, String) -> Void
    let onDelete: () -> Void

    init(
        setNumber: Int,
        weight: String,
        reps: String,
        onChange: @escaping (String, String) -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.setNumber = setNumber
        self._weightText = State(initialValue: weight)
        self._repsText = State(initialValue: reps)
        self.onChange = onChange
        self.onDelete = onDelete
    }

    var body: some View {
        HStack(spacing: 8) {
            Text("\(setNumber)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.65))
                .frame(width: 38, alignment: .leading)

            TextField("45 kg", text: $weightText)
                .font(.system(size: 13, weight: .semibold))
                .padding(.vertical, 9)
                .padding(.horizontal, 10)
                .background(Color.white.opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .onChange(of: weightText) { _ in
                    onChange(weightText, repsText)
                }

            TextField("10", text: $repsText)
                .keyboardType(.numberPad)
                .font(.system(size: 13, weight: .semibold))
                .padding(.vertical, 9)
                .padding(.horizontal, 10)
                .background(Color.white.opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .frame(width: 64)
                .onChange(of: repsText) { _ in
                    onChange(weightText, repsText)
                }
        }
        .padding(.vertical, 2)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
