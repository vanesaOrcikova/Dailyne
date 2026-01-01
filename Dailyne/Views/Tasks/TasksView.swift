//
//  TasksView.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 28/12/2025.
//

import SwiftUI

struct TasksView: View {

    @EnvironmentObject var schoolStore: SchoolStore

    @State private var isAddSubjectPresented: Bool = false

    @State private var isRenamePresented: Bool = false
    @State private var subjectToRename: Subject? = nil

    @State private var subjectToDelete: Subject? = nil
    @State private var isDeleteAlertPresented: Bool = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.98, green: 0.94, blue: 0.95)
                    .ignoresSafeArea()

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(schoolStore.subjects) { subject in
                            NavigationLink {
                                TasksSubjectDetailView(subjectId: subject.id)
                            } label: {
                                TasksSubjectCardView(subject: subject)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button("Rename") {
                                    subjectToRename = subject
                                    isRenamePresented = true
                                }

                                Button("Delete", role: .destructive) {
                                    subjectToDelete = subject
                                    isDeleteAlertPresented = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddSubjectPresented = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(10)
                            .background(Color.black.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .sheet(isPresented: $isAddSubjectPresented) {
                AddSubjectView { name in
                    schoolStore.addSubject(name: name)
                }
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $isRenamePresented) {
                if let subject = subjectToRename {
                    EditSubjectView(title: "Rename", currentName: subject.name) { newName in
                        schoolStore.renameSubject(subjectId: subject.id, newName: newName)
                    }
                    .presentationDetents([.medium])
                }
            }
            .alert("Delete subject?", isPresented: $isDeleteAlertPresented) {
                Button("Delete", role: .destructive) {
                    if let s = subjectToDelete {
                        schoolStore.deleteSubject(subjectId: s.id)
                    }
                    subjectToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    subjectToDelete = nil
                }
            } message: {
                Text("This will remove the subject and all its tasks.")
            }
        }
    }
}

#Preview {
    let store = SchoolStore()
    store.subjects = [
        Subject(name: "Mathematics", tasks: [
            SchoolTask(title: "Homework 1", type: .assignment),
            SchoolTask(title: "Study lecture notes", type: .study),
            SchoolTask(title: "Test result", type: .points, pointsEarned: 4, pointsTotal: 30)
        ]),
        Subject(name: "Physics", tasks: [
            SchoolTask(title: "Lab report", type: .assignment)
        ])
    ]

    return TasksView()
        .environmentObject(store)
}
