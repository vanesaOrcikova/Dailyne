//
//  AddSubjectView.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 28/12/2025.
//

import SwiftUI

struct AddSubjectView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""

    let onAdd: (String) -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {

                Text("Create a subject")
                    .font(.title3)
                    .fontWeight(.semibold)

                TextField("e.g. Mathematics", text: $name)
                    .textFieldStyle(.roundedBorder)

                Spacer()
            }
            .padding()
            .navigationTitle("New Subject")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(name)
                        dismiss()
                    }
                    .disabled(
                        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }
            }
        }
    }
}

#Preview {
    AddSubjectView { _ in }
}
