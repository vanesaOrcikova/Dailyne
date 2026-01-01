//
//  EditSubjectView.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 29/12/2025.
//

import SwiftUI

struct EditSubjectView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var name: String

    let title: String
    let onSave: (String) -> Void

    init(title: String, currentName: String, onSave: @escaping (String) -> Void) {
        self.title = title
        self._name = State(initialValue: currentName)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {

                TextField("Subject name", text: $name)
                    .textFieldStyle(.roundedBorder)

                Spacer()
            }
            .padding()
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            onSave(trimmed)
                            dismiss()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    EditSubjectView(title: "Rename", currentName: "Mathematics") { _ in }
}
