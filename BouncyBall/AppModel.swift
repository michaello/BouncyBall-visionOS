import SwiftUI
import RealityKit

@MainActor
@Observable
class AppModel {
    let physicsManager = PhysicsManager()
    
    var dropHeight: Float = 0.5
    var ballRadius: Float = 0.05
    var hitForce: Float = 50.0
    var linearDamping: Float = 0.1
    var angularDamping: Float = 0.1
    var staticFriction: Float = 0.5
    var dynamicFriction: Float = 0.5
    
    var physicsParams: PhysicsManager.PhysicsParams {
        PhysicsManager.PhysicsParams(
            staticFriction: staticFriction,
            dynamicFriction: dynamicFriction
        )
    }
}