//
//  AddSchoolTaskView.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 28/12/2025.
//

import SwiftUI

struct AddSchoolTaskView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var type: SchoolTaskType = .assignment

    @State private var priority: TaskPriority = .normal
    @State private var dueDate: Date = Date()

    @State private var pointsEarnedText: String = ""
    @State private var pointsTotalText: String = ""

    @State private var note: String = ""

    // onAdd: (title, note, type, priority, dueDate, earned, total)
    let onAdd: (String, String, SchoolTaskType, TaskPriority, Date?, Int?, Int?) -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {

                Text("New Task")
                    .font(.system(size: 40, weight: .bold))
                    .padding(.top, 6)

                // Title
                TextField("Task title (e.g. Homework page 12)", text: $title)
                    .textFieldStyle(.roundedBorder)

                // Type (Assignment / Study / Points)
                Picker("Type", selection: $type) {
                    Text("Assignment").tag(SchoolTaskType.assignment)
                    Text("Study").tag(SchoolTaskType.study)
                    Text("Points").tag(SchoolTaskType.points)
                }
                .pickerStyle(.segmented)

                // Priority (len pre Assignment/Study)
                if type != .points {
                    HStack {
                        Text("Priority")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.secondary)

                        Spacer()

                        Picker("Priority", selection: $priority) {
                            Text("—").tag(TaskPriority.normal)
                            Text("!").tag(TaskPriority.important)
                            Text("!!!").tag(TaskPriority.urgent)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 190)
                    }
                }

                // Due (len pre Assignment)
                if type == .assignment {
                    DatePicker("Due", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                }

                // Points (len pre Points)
                if type == .points {
                    HStack(spacing: 10) {
                        TextField("earned", text: $pointsEarnedText)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)

                        Text("/")
                            .foregroundStyle(.secondary)

                        TextField("total", text: $pointsTotalText)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                // ✅ NOTE box: 2–3 riadky a rastie podľa textu + placeholder vnútri
                AutoGrowingTextEditor(text: $note, placeholder: "Note (optional)")
                    .padding(.top, 6)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmedTitle.isEmpty { return }

                        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)

                        let due: Date? = (type == .assignment) ? dueDate : nil
                        let earned: Int? = (type == .points) ? Int(pointsEarnedText) : nil
                        let total: Int? = (type == .points) ? Int(pointsTotalText) : nil

                        onAdd(trimmedTitle, trimmedNote, type, priority, due, earned, total)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddSchoolTaskView { _, _, _, _, _, _, _ in }
}
