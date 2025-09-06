//
//  HabitooApp.swift
//  Habitoo
//
//  Created by Pedro Juan Ferreira Saraiva on 31/08/25.
//

import SwiftUI

@main
struct HabitooApp: App {
    @StateObject private var session = AppSession()

    var body: some Scene {
        WindowGroup {
            AuthView()
                .environmentObject(session)
        }
    }
}
