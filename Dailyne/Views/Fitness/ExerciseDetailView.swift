//
//  ExerciseDetailView.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 23/01/2026.
//

import SwiftUI
import PhotosUI
import UIKit

struct ExerciseDetailView: View {

    @Environment(\.dismiss) private var dismiss

    let exerciseName: String
    let existingPhotoData: Data?
    let onSavePhoto: (Data?) -> Void

    @State private var pickerItem: PhotosPickerItem? = nil
    @State private var newPhotoData: Data? = nil

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {

                Text(exerciseName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.85))

                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.black.opacity(0.04))
                        .frame(height: 220)

                    if let data = newPhotoData ?? existingPhotoData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(Color.black.opacity(0.25))
                            Text("Add a photo of this exercise")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.black.opacity(0.45))
                        }
                    }
                }

                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Text("+ Choose from Gallery")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .onChange(of: pickerItem) { item in
                    guard let item else { return }
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            await MainActor.run {
                                newPhotoData = data
                            }
                        }
                    }
                }

                Button {
                    onSavePhoto(newPhotoData ?? existingPhotoData)
                    dismiss()
                } label: {
                    Text("Save")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)

                Button(role: .destructive) {
                    onSavePhoto(nil)
                    dismiss()
                } label: {
                    Text("Remove photo")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(20)
            .navigationTitle("Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
