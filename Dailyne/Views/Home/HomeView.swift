//
//  HomeView.swift
//  SoftLifePlanner
//
//  Created by Vanesa Orcikova on 28/12/2025.
//

import SwiftUI

struct HomeView: View {

    private let name: String = "Vanesa"
    @State private var selectedMoodIndex: Int = 1

    // user's own daily priorities
    @State private var priorities: [PriorityItem] = []
    @State private var isAddPriorityPresented: Bool = false

    // 🌱 Grow a Thought
    @StateObject private var growStore = GrowThoughtStore()
    @State private var showGrowDetail: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.98, green: 0.94, blue: 0.95)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {

                        // Greeting
                        Text("Good \(GreetingHelper.greeting()), \(name)")
                            .font(.system(size: 28, weight: .semibold))
                            .padding(.top, 80)

                        // Mood Check-In
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Mood Check-In")
                                .font(.system(size: 23, weight: .semibold))

                            MoodPickerView(selectedIndex: $selectedMoodIndex)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                        // Today's Priorities
                        VStack(alignment: .leading, spacing: 12) {

                            HStack {
                                Text("Today's Priorities")
                                    .font(.system(size: 23, weight: .semibold))

                                Spacer()

                                Button {
                                    isAddPriorityPresented = true
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .semibold))
                                        .padding(8)
                                        .background(Color.black.opacity(0.06))
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                            }

                            if priorities.isEmpty {
                                Text("Add small things you want to do today ✨")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.black.opacity(0.5))
                                    .padding(.top, 4)
                            } else {
                                ForEach($priorities) { $item in
                                    PriorityRowView(item: $item)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                        // 🌱 Grow a Thought widget (NOVÉ)
                        GrowThoughtWidgetCard(store: growStore) { showGrowDetail = true }
                        .sheet(isPresented: $showGrowDetail) {
                            GrowThoughtDetailView(store: growStore)
                                .presentationDetents([.medium, .large])
                        }

                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .sheet(isPresented: $isAddPriorityPresented) {
                AddPriorityView { text in
                    priorities.append(PriorityItem(title: text))
                }
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showGrowDetail) {
                GrowThoughtDetailView(store: growStore)
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

#Preview {
    HomeView()
}
