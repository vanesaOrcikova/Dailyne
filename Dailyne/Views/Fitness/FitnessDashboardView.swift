//
//  FitnessDashboardView.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 07/01/2026.
//

import SwiftUI

struct FitnessDashboardView: View {

    @EnvironmentObject var fitnessStore: FitnessStore

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.94, blue: 0.95)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {

                    // 1) Weekly goal card
                    SoftCard {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Weekly goal")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Color.black.opacity(0.8))

                                Spacer()

                                HStack(spacing: 10) {
                                    Button {
                                        fitnessStore.decreaseWeeklyGoal()
                                    } label: {
                                        Image(systemName: "minus")
                                            .font(.system(size: 13, weight: .bold))
                                            .frame(width: 28, height: 28)
                                            .background(Color.black.opacity(0.06))
                                            .clipShape(Circle())
                                    }
                                    .buttonStyle(.plain)

                                    Text("\(fitnessStore.weeklyGoal)")
                                        .font(.system(size: 15, weight: .semibold))
                                        .frame(minWidth: 24)

                                    Button {
                                        fitnessStore.increaseWeeklyGoal()
                                    } label: {
                                        Image(systemName: "plus")
                                            .font(.system(size: 13, weight: .bold))
                                            .frame(width: 28, height: 28)
                                            .background(Color.black.opacity(0.06))
                                            .clipShape(Circle())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            WeekProgressRow(
                                selectedDays: fitnessStore.workoutDaysThisWeek,
                                onTapDay: { day in
                                    fitnessStore.toggleWorkoutDay(day)
                                }
                            )

                            Text("\(fitnessStore.completedThisWeek) / \(fitnessStore.weeklyGoal) completed")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.black.opacity(0.55))
                        }
                    }

                    // 2) Quote card
                    SoftCard {
                        Text("“\(fitnessStore.quote)”")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(0.75))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // 3) Habits card
                    SoftCard {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Habits today")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Color.black.opacity(0.8))

                                Spacer()

                                Button("Reset") {
                                    fitnessStore.resetHabitsNow()
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.black.opacity(0.55))
                            }

                            HStack(spacing: 10) {
                                HabitButton(icon: "🚶", isOn: fitnessStore.habitWalk) {
                                    fitnessStore.toggleHabit(.walk)
                                }
                                HabitButton(icon: "💧", isOn: fitnessStore.habitWater) {
                                    fitnessStore.toggleHabit(.water)
                                }
                                HabitButton(icon: "😴", isOn: fitnessStore.habitSleep) {
                                    fitnessStore.toggleHabit(.sleep)
                                }
                                HabitButton(icon: "🧘", isOn: fitnessStore.habitStretch) {
                                    fitnessStore.toggleHabit(.stretch)
                                }
                            }
                        }
                    }

                    // 4) Log button card
                    SoftCard {
                        Button {
                            // neskôr: otvoríme LogWellnessView
                        } label: {
                            HStack {
                                Text("+ Log today’s workout")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Color.black.opacity(0.8))
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
    }
}

// MARK: - Small reusable card

private struct SoftCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Week row

private struct WeekProgressRow: View {

    let selectedDays: Set<Weekday>
    let onTapDay: (Weekday) -> Void

    var body: some View {
        HStack(spacing: 12) {
            ForEach(Weekday.allCases) { day in
                Button {
                    onTapDay(day)
                } label: {
                    VStack(spacing: 6) {
                        Text(day.short)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(0.65))

                        Text(selectedDays.contains(day) ? "●" : "○")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.black.opacity(selectedDays.contains(day) ? 0.75 : 0.25))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(Color.black.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Habits

private struct HabitButton: View {
    let icon: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 6) {
                Text(icon).font(.system(size: 16))
                Text(isOn ? "●" : "○")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.black.opacity(isOn ? 0.75 : 0.25))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(isOn ? Color.black.opacity(0.08) : Color.black.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FitnessDashboardView()
        .environmentObject(FitnessStore())
}
