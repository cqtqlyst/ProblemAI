//
//  ProblemAIApp.swift
//  ProblemAI
//
//  Created by Nikhil Krishnaswamy on 7/21/23.
//

import SwiftUI

@main
struct ProblemAIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
