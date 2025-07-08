//
//  BouncyBallApp.swift
//  BouncyBall
//
//  Created by Mike Pyrka on 08.07.2025.
//

import SwiftUI

@main
struct BouncyBallApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .windowStyle(.volumetric)
    }
}
