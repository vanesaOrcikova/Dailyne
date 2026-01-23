//
//  SubjectDetailView.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 28/12/2025.
//

import SwiftUI

struct TasksSubjectDetailView: View {

    @EnvironmentObject var schoolStore: SchoolStore

    let subjectId: UUID
    @State private var isAddTaskPresented: Bool = false

    @State private var isEditPresented: Bool = false
    @State private var taskToEdit: SchoolTask? = nil

    var subject: SchoolSubject? {
        schoolStore.subjects.first(where: { $0.id == subjectId })
    }

    var body: some View {
        List {
            if let subject {

                // ✅ ASSIGNMENTS: nesplnené hore, splnené dole
                let assignments = subject.tasks
                    .filter { $0.type == .assignment }
                    .sorted { a, b in
                        if a.isDone != b.isDone { return a.isDone == false }
                        if a.priority.rawValue != b.priority.rawValue { return a.priority.rawValue > b.priority.rawValue }
                        if let da = a.dueDate, let db = b.dueDate { return da < db }
                        if a.dueDate != nil && b.dueDate == nil { return true }
                        if a.dueDate == nil && b.dueDate != nil { return false }
                        return a.title.lowercased() < b.title.lowercased()
                    }

                // ✅ STUDY: nesplnené hore, splnené dole
                let studies = subject.tasks
                    .filter { $0.type == .study }
                    .sorted { a, b in
                        if a.isDone != b.isDone { return a.isDone == false }
                        if a.priority.rawValue != b.priority.rawValue { return a.priority.rawValue > b.priority.rawValue }
                        return a.title.lowercased() < b.title.lowercased()
                    }

                // Points = poznámky / body
                let pointsNotes = subject.tasks.filter { $0.type == .points }

                // MARK: - Assignments
                Section("Assignments") {
                    if assignments.isEmpty {
                        Text("No assignments yet ✨")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(assignments) { task in
                            taskRow(task: task, showPriority: true, showDueDate: true)
                        }
                    }
                }

                // MARK: - Study
                Section("Study") {
                    if studies.isEmpty {
                        Text("No study tasks yet ✨")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(studies) { task in
                            taskRow(task: task, showPriority: true, showDueDate: false)
                        }
                    }
                }

                // MARK: - Points
                Section("Points") {
                    if pointsNotes.isEmpty {
                        Text("No points notes yet ✨")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(pointsNotes) { task in
                            pointsRow(task: task)
                        }
                    }
                }

            } else {
                Text("Subject not found")
            }
        }
        .navigationTitle(subject?.name ?? "Subject")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isAddTaskPresented = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isAddTaskPresented) {
            AddSchoolTaskView { title, note, type, priority, dueDate, earned, total in
                schoolStore.addTask(
                    to: subjectId,
                    title: title,
                    note: note,
                    type: type,
                    priority: priority,
                    dueDate: dueDate,
                    pointsEarned: earned,
                    pointsTotal: total
                )
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $isEditPresented) {
            if let task = taskToEdit {
                EditSchoolTaskView(task: task) { updated in
                    schoolStore.updateTask(subjectId: subjectId, updatedTask: updated)
                }
                .presentationDetents([.medium])
            }
        }
    }

    // MARK: - Row pre Assignment/Study
    @ViewBuilder
    private func taskRow(task: SchoolTask, showPriority: Bool, showDueDate: Bool) -> some View {
        HStack(spacing: 10) {

            Button {
                schoolStore.toggleTask(subjectId: subjectId, taskId: task.id)
            } label: {
                Image(systemName: task.isDone ? "checkmark.square.fill" : "square")
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {

                HStack(spacing: 8) {
                    Text(task.title)
                        .strikethrough(task.isDone)
                        .foregroundStyle(Color.black.opacity(task.isDone ? 0.45 : 0.9))

                    if showPriority && task.priority != .normal {
                        Text(task.priority.label)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }

                if showDueDate, let due = task.dueDate {
                    Text("Due: \(due.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // ✅ NOTE úplne dole
                if !task.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(task.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 2)
                }
            }

            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            taskToEdit = task
            isEditPresented = true
        }
        // ✅ SWIPE DELETE
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                schoolStore.deleteTask(subjectId: subjectId, taskId: task.id)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Row pre Points
    @ViewBuilder
    private func pointsRow(task: SchoolTask) -> some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(task.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.9))

            if let e = task.pointsEarned, let t = task.pointsTotal {
                Text("Points: \(e)/\(t)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Points")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // ✅ NOTE úplne dole
            if !task.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(task.note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            taskToEdit = task
            isEditPresented = true
        }
        // ✅ SWIPE DELETE aj pre points
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                schoolStore.deleteTask(subjectId: subjectId, taskId: task.id)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

