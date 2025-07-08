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
            setupPhysicsScene(content)
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
    
    private func setupPhysicsScene(_ content: RealityViewContent) {
        let ground = ModelEntity(
            mesh: .generateBox(width: 0.5, height: 0.02, depth: 0.5),
            materials: [SimpleMaterial(color: .gray, isMetallic: false)]
        )
        ground.position = [0, -0.01, 0]
        
        let groundPhysics = PhysicsBodyComponent(
            massProperties: .default,
            material: .generate(staticFriction: 0.8, dynamicFriction: 0.5, restitution: 1.0),
            mode: .static
        )
        ground.components.set(groundPhysics)
        ground.generateCollisionShapes(recursive: false)
        
        content.add(ground)
        
        let light = DirectionalLight()
        light.light.intensity = 5000
        light.orientation = simd_quatf(angle: -.pi / 4, axis: [1, 0, 0])
        content.add(light)
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
