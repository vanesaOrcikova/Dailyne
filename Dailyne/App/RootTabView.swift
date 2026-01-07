//
//  RootTabView.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 28/12/2025.
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }

            TasksView()
                .tabItem { Label("Tasks", systemImage: "list.bullet") }

            Text("Diary")
                .tabItem { Label("Diary", systemImage: "camera") }

            FitnessView()
                .tabItem { Label("Fitness", systemImage: "heart") }

            Text("Board")
                .tabItem { Label("Board", systemImage: "square.grid.2x2") }
        }
        .tint(Color(red: 0.86, green: 0.36, blue: 0.45))
    }
}

#Preview {
    RootTabView()
        .environmentObject(SchoolStore())
}
