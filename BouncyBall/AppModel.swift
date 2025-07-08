import SwiftUI
import RealityKit
import Combine

@MainActor
@Observable
class AppModel {
    let physicsManager = PhysicsManager()
    
    var dropHeight: Float = 0.5
    var ballRadius: Float = 0.05
    var hitForce: Float = 50.0
    var linearDamping: Float = 0.0
    var angularDamping: Float = 0.0
    var staticFriction: Float = 0.5
    var dynamicFriction: Float = 0.5
    
    var bounceCount: Int = 0
    
    private var cancellable: AnyCancellable?
    
    init() {
        cancellable = physicsManager.$bounceCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newCount in
                self?.bounceCount = newCount
            }
    }
    
    var physicsParams: PhysicsManager.PhysicsParams {
        PhysicsManager.PhysicsParams(
            staticFriction: staticFriction,
            dynamicFriction: dynamicFriction,
            linearDamping: linearDamping,
            angularDamping: angularDamping
        )
    }
}