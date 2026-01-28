//
//  WorkoutDayTabsView.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 28/01/2026.
//

import SwiftUI

struct WorkoutDayTabsView: View {
    let days: [WorkoutDay]
    @Binding var selectedId: UUID?

    let onAddDay: () -> Void
    let onRenameDay: (WorkoutDay) -> Void
    let onDeleteDay: (WorkoutDay) -> Void
    let onSelectDay: (WorkoutDay) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {

                Button {
                    onAddDay()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.55))
                        .frame(width: 34, height: 28)
                        .background(Color.white.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)

                ForEach(days) { day in
                    let isSelected = (selectedId == day.id)

                    Button {
                        selectedId = day.id
                        onSelectDay(day)
                    } label: {
                        Text(day.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(isSelected ? 0.85 : 0.55))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(isSelected ? 0.85 : 0.60))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button("Rename") { onRenameDay(day) }
                        Button(role: .destructive) {
                            onDeleteDay(day)
                        } label: {
                            Text("Delete")
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
