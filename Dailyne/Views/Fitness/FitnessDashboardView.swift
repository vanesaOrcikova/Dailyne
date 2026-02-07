//
//  FitnessDashboardView.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 07/01/2026.
//

import SwiftUI

struct FitnessDashboardView: View {
    
    @State private var showWorkoutPlan: Bool = false

    @ObservedObject var fitnessStore: FitnessStore

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
                            }

                            WeekProgressRow(
                                selectedDays: fitnessStore.workoutDaysThisWeek,
                                onTapDay: { day in
                                    fitnessStore.toggleWorkoutDay(day)
                                }
                            )

                            Text("Workouts: \(fitnessStore.workoutDaysThisWeek.count) / 7 days")
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
                    
                    // 3) Body feeling card
                    SoftCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("How did your body feel?")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.black.opacity(0.8))

                            HeartRatingView(rating: $fitnessStore.bodyFeelingRating)
                            WeeklyFeelingMiniView(values: fitnessStore.feelingForCurrentWeek())
                                .padding(.top, 8)
                        }
                    }

                    // 4) Habits card
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
                                    fitnessStore.toggleHabit(.activity)
                                }
                            }
                        }
                    }

                    // 4) Log button card
                    SoftCard {
                        Button {
                            showWorkoutPlan = true
                        } label: {
                            HStack {
                                Text("+ Workout Plan")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Color.black.opacity(0.8))
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                        .sheet(isPresented: $showWorkoutPlan) {
                            WorkoutPlanView()
                                .presentationDetents([.large])
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
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

private struct HeartRatingView: View {

    @Binding var rating: Int   // 0–5

    var body: some View {
        HStack(spacing: 10) {
            ForEach(1...5, id: \.self) { index in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        // ✅ ak klikneš na rovnaký index, vypne sa na 0
                        if rating == index {
                            rating = 0
                        } else {
                            rating = index
                        }
                    }
                } label: {
                    Image(systemName: index <= rating ? "heart.fill" : "heart")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(index <= rating
                                         ? Color(red: 0.86, green: 0.36, blue: 0.45)
                                         : Color.black.opacity(0.25))
                        .frame(width: 34, height: 34)
                        .background(Color.black.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        // ✅ jemný “pop” efekt
                        .scaleEffect(index <= rating ? 1.03 : 1.0)
                        .animation(.easeInOut(duration: 0.25), value: rating)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 6)
        .background(Color.black.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct WeeklyFeelingMiniView: View {

    let values: [Int] // 0–5, 7 dní

    var body: some View {
        HStack(spacing: 8) {
            ForEach(values.indices, id: \.self) { i in
                let v = values[i]
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundStyle(
                        v == 0
                        ? Color.black.opacity(0.12)
                        : Color(red: 0.86, green: 0.36, blue: 0.45).opacity(0.25 + (Double(v) * 0.12))
                    )
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color.black.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
    FitnessDashboardView(fitnessStore: FitnessStore())
}
