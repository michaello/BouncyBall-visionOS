//
//  ContentView.swift
//  BouncyBall
//
//  Created by Mike Pyrka on 08.07.2025.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    
    @State private var contentForOrnament: RealityViewContent?

    var body: some View {
        RealityView { content in
            contentForOrnament = content
            appModel.physicsManager.setupPhysicsScene(content)
        }
        .ornament(
            visibility: .visible,
            attachmentAnchor: .scene(.trailing),
            contentAlignment: .center
        ) {
            if contentForOrnament != nil {
                @Bindable var appModelBinding = appModel
                BallControlsOrnament(
                    appModel: appModel,
                    dropHeight: $appModelBinding.dropHeight,
                    ballRadius: $appModelBinding.ballRadius,
                    hitForce: $appModelBinding.hitForce,
                    linearDamping: $appModelBinding.linearDamping,
                    angularDamping: $appModelBinding.angularDamping,
                    staticFriction: $appModelBinding.staticFriction,
                    dynamicFriction: $appModelBinding.dynamicFriction,
                    onDropBall: {
                        dropBall()
                    },
                    onHitBall: {
                        appModel.physicsManager.hitBall(force: appModel.hitForce)
                    }
                )
                .glassBackgroundEffect()
            }
        }
    }
    
    private func dropBall() {
        guard let content = contentForOrnament else { return }
        
        let dropPosition = SIMD3<Float>(0, appModel.dropHeight, 0)
        appModel.physicsManager.dropBall(
            in: content,
            at: dropPosition,
            radius: appModel.ballRadius,
            physicsParams: appModel.physicsParams
        )
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
