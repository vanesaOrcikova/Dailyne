//
//  DailyneApp.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 28/12/2025.
//

import SwiftUI

@main
struct DailyneApp: App {

    @StateObject private var schoolStore = SchoolStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(schoolStore)
        }
    }
}
