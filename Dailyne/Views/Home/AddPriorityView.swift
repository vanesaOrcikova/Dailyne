//
//  AddPriorityView.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 28/12/2025.
//

import SwiftUI

struct AddPriorityView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var text: String = ""

    let onAdd: (String) -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {

                Text("Add a priority")
                    .font(.title3)
                    .fontWeight(.semibold)

                TextField("e.g. clean room, gym, study 30 min…", text: $text)
                    .textFieldStyle(.roundedBorder)

                Spacer()
            }
            .padding()
            .navigationTitle("New Priority")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            onAdd(trimmed)
                            dismiss()
                        }
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddPriorityView { _ in }
}


