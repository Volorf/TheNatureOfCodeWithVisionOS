//
//  TheNatureOfCodeWithVisionOSApp.swift
//  TheNatureOfCodeWithVisionOS
//
//  Created by Oleg Frolov on 26/02/2025.
//

import SwiftUI

@main
struct TheNatureOfCodeWithVisionOSApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .windowStyle(.volumetric)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
