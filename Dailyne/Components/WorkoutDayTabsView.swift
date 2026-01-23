//
//  WorkoutDayTabsView.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 23/01/2026.
//

import SwiftUI

struct WorkoutDayTabsView: View {

    let days: [WorkoutPlanStore.Day]
    @Binding var selectedId: UUID?

    let onAddDay: () -> Void
    let onRenameDay: (WorkoutPlanStore.Day) -> Void
    let onDeleteDay: (WorkoutPlanStore.Day) -> Void
    let onSelectDay: (WorkoutPlanStore.Day) -> Void

    var body: some View {
        SoftCard {
            HStack(spacing: 10) {

                // ✅ iba plus v prvom “ramiku”
                Button {
                    onAddDay()
                } label: {
                    Text("+")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.75))
                        .frame(width: 44, height: 34)
                        .background(Color.black.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                // kategórie
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(days) { day in
                            Button {
                                onSelectDay(day)
                            } label: {
                                Text(day.title)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Color.black.opacity(selectedId == day.id ? 0.85 : 0.55))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color.black.opacity(selectedId == day.id ? 0.08 : 0.04))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button("Rename") { onRenameDay(day) }
                                Button("Delete", role: .destructive) { onDeleteDay(day) }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}
