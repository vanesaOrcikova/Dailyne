//
//  EditSchoolTaskView.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 29/12/2025.
//

import SwiftUI

struct EditSchoolTaskView: View {

    @Environment(\.dismiss) private var dismiss

    let originalTask: SchoolTask
    let onSave: (SchoolTask) -> Void

    @State private var title: String
    @State private var type: SchoolTaskType

    @State private var priority: TaskPriority
    @State private var dueDate: Date

    @State private var pointsEarnedText: String
    @State private var pointsTotalText: String

    // ✅ note je na konci
    @State private var note: String

    init(task: SchoolTask, onSave: @escaping (SchoolTask) -> Void) {
        self.originalTask = task
        self.onSave = onSave

        _title = State(initialValue: task.title)
        _type = State(initialValue: task.type)

        _priority = State(initialValue: task.priority)
        _dueDate = State(initialValue: task.dueDate ?? Date())

        _pointsEarnedText = State(initialValue: task.pointsEarned.map(String.init) ?? "")
        _pointsTotalText = State(initialValue: task.pointsTotal.map(String.init) ?? "")

        _note = State(initialValue: task.note)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {

                TextField("Title", text: $title)
                    .textFieldStyle(.roundedBorder)

                Picker("Type", selection: $type) {
                    Text("Assignment").tag(SchoolTaskType.assignment)
                    Text("Study").tag(SchoolTaskType.study)
                    Text("Points").tag(SchoolTaskType.points)
                }
                .pickerStyle(.segmented)

                // Priority len pre Assignment/Study
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

                // Due len pre Assignment
                if type == .assignment {
                    DatePicker("Due", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                }

                // Points len pre Points
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

                // ✅ NOTE úplne dole (rovnaké ako Add)
                AutoGrowingTextEditor(text: $note, placeholder: "Note (optional)")
                    .padding(.top, 6)

                Spacer()
            }
            .padding()
            .navigationTitle("Edit Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmedTitle.isEmpty { return }

                        var updated = originalTask
                        updated.title = trimmedTitle
                        updated.type = type

                        if type == .assignment || type == .study {
                            updated.priority = priority
                        } else {
                            updated.priority = .normal
                        }

                        updated.dueDate = (type == .assignment) ? dueDate : nil

                        if type == .points {
                            updated.pointsEarned = Int(pointsEarnedText)
                            updated.pointsTotal = Int(pointsTotalText)
                        } else {
                            updated.pointsEarned = nil
                            updated.pointsTotal = nil
                        }

                        updated.note = note.trimmingCharacters(in: .whitespacesAndNewlines)

                        onSave(updated)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    EditSchoolTaskView(
        task: SchoolTask(
            title: "Homework 3",
            note: "",
            type: .assignment,
            priority: .important,
            dueDate: Date()
        )
    ) { _ in }
}
