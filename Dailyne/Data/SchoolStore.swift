//
//  SchoolStore.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 28/12/2025.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class SchoolStore: ObservableObject {
    
    // uloženie do UserDefaults cez AppStorage
    @AppStorage("schoolSubjectsData") private var schoolSubjectsData: Data = Data()
    
    @Published var subjects: [SchoolSubject] = [] {
        didSet {
            save()
        }
    }
    
    init() {
        load()
    }
    
    // MARK: - Subjects
    
    func addSubject(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return }
        subjects.append(SchoolSubject(name: trimmed))
    }
    
    func renameSubject(subjectId: UUID, newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return }
        guard let index = subjects.firstIndex(where: { $0.id == subjectId }) else { return }
        subjects[index].name = trimmed
    }
    
    func deleteSubject(subjectId: UUID) {
        subjects.removeAll { $0.id == subjectId }
    }
    
    // MARK: - Tasks
    
    func addTask(
        to subjectId: UUID,
        title: String,
        note: String,
        type: SchoolTaskType,
        priority: TaskPriority,
        dueDate: Date?,
        pointsEarned: Int?,
        pointsTotal: Int?
    ) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return }
        guard let index = subjects.firstIndex(where: { $0.id == subjectId }) else { return }
        
        var newTask = SchoolTask(title: trimmed, note: note, type: type)
        
        // priority len pre assignment+study
        if type == .assignment || type == .study {
            newTask.priority = priority
        } else {
            newTask.priority = .normal
        }
        
        if type == .assignment {
            newTask.dueDate = dueDate
        }
        
        if type == .points {
            newTask.pointsEarned = pointsEarned
            newTask.pointsTotal = pointsTotal
        }
        
        subjects[index].tasks.append(newTask)
    }
    
    func toggleTask(subjectId: UUID, taskId: UUID) {
        guard let sIndex = subjects.firstIndex(where: { $0.id == subjectId }) else { return }
        guard let tIndex = subjects[sIndex].tasks.firstIndex(where: { $0.id == taskId }) else { return }
        subjects[sIndex].tasks[tIndex].isDone.toggle()
    }
    
    // ✅ DOPLNENÉ: swipe delete pre úlohy (Assignment/Study/Points)
    func deleteTask(subjectId: UUID, taskId: UUID) {
        guard let sIndex = subjects.firstIndex(where: { $0.id == subjectId }) else { return }
        subjects[sIndex].tasks.removeAll { $0.id == taskId }
    }
    
    func sortedTodoTasks(for subjectId: UUID) -> [SchoolTask] {
        guard let subject = subjects.first(where: { $0.id == subjectId }) else { return [] }
        let todo = subject.tasks.filter { $0.type != .points }
        
        return todo.sorted { a, b in
            if a.priority.rawValue != b.priority.rawValue {
                return a.priority.rawValue > b.priority.rawValue
            }
            return a.title.lowercased() < b.title.lowercased()
        }
    }
    
    func pointNotes(for subjectId: UUID) -> [SchoolTask] {
        guard let subject = subjects.first(where: { $0.id == subjectId }) else { return [] }
        return subject.tasks.filter { $0.type == .points }
    }
    
    func updateTask(subjectId: UUID, updatedTask: SchoolTask) {
        guard let sIndex = subjects.firstIndex(where: { $0.id == subjectId }) else { return }
        guard let tIndex = subjects[sIndex].tasks.firstIndex(where: { $0.id == updatedTask.id }) else { return }
        subjects[sIndex].tasks[tIndex] = updatedTask
    }
    
    // MARK: - Persistence
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(subjects)
            schoolSubjectsData = data
        } catch {
            // ak by sa niečo pokazilo, necháme aspoň appku bežať
        }
    }
    
    private func load() {
        guard !schoolSubjectsData.isEmpty else {
            subjects = []
            return
        }
        
        do {
            subjects = try JSONDecoder().decode([SchoolSubject].self, from: schoolSubjectsData)
        } catch {
            subjects = []
        }
    }
}
