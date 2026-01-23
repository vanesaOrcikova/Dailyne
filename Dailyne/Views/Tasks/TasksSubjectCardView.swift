//
//  SubjectCardView.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 28/12/2025.
//

import SwiftUI

struct TasksSubjectCardView: View {

    var subject: SchoolSubject

    // ✅ úlohy na kartičke:
    // - bez Points
    // - nesplnené hore, splnené dole
    // - zobrazíme max 2
    private var previewTasks: [SchoolTask] {
        let filtered = subject.tasks.filter { $0.type != .points }

        let sorted = filtered.sorted { a, b in
            if a.isDone != b.isDone {
                return a.isDone == false // false (nedone) ide hore
            }
            return a.title.lowercased() < b.title.lowercased()
        }

        return Array(sorted.prefix(3))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(subject.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.85))

            VStack(alignment: .leading, spacing: 6) {
                if previewTasks.isEmpty {
                    Text("No tasks yet ✨")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.black.opacity(0.45))
                        .lineLimit(1)
                } else {
                    ForEach(previewTasks) { task in
                        Text("• \(task.title)")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.black.opacity(task.isDone ? 0.35 : 0.65))
                            .strikethrough(task.isDone)
                            .lineLimit(1)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(height: 110)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

