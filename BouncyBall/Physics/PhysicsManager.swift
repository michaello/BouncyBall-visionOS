import RealityKit
import SwiftUI
import Combine

@MainActor
class PhysicsManager: ObservableObject {
    @Published var bounceCount: Int = 0
    @Published var ballEntity: Entity?
    
    private var collisionSubscription: AnyCancellable?
    private var lastCollisionTime: Date = .distantPast
    private let collisionDebounceThreshold: TimeInterval = 0.1
    
    struct PhysicsParams {
        var staticFriction: Float = 0.5
        var dynamicFriction: Float = 0.5
    }
    
    func dropBall(
        in content: RealityViewContent,
        at position: SIMD3<Float>,
        radius: Float,
        physicsParams: PhysicsParams
    ) {
        removeBall(from: content)
        bounceCount = 0
        
        let ball = createBall(radius: radius, physicsParams: physicsParams)
        ball.position = position
        
        content.add(ball)
        ballEntity = ball
        
        setupCollisionDetection(for: ball)
    }
    
    private func createBall(radius: Float, physicsParams: PhysicsParams) -> ModelEntity {
        let ball = ModelEntity(
            mesh: .generateSphere(radius: radius),
            materials: [SimpleMaterial(color: .systemBlue, isMetallic: true)]
        )
        
        let physicsBody = PhysicsBodyComponent(
            massProperties: .init(mass: 0.001),
            material: .generate(
                staticFriction: physicsParams.staticFriction,
                dynamicFriction: physicsParams.dynamicFriction,
                restitution: 1.0
            ),
            mode: .dynamic
        )
        
        ball.components.set(physicsBody)
        
        let physicsMotion = PhysicsMotionComponent(
            linearVelocity: [0, 0, 0],
            angularVelocity: [0, 0, 0]
        )
        
        ball.components.set(physicsMotion)
        ball.generateCollisionShapes(recursive: false)
        
        return ball
    }
    
    private func setupCollisionDetection(for ball: Entity) {
        collisionSubscription?.cancel()
        
        guard let scene = ball.scene else { return }
        
        let subscription = scene.subscribe(
            to: CollisionEvents.Began.self,
            on: ball
        ) { [weak self] event in
            guard let self = self else { return }
            
            let currentTime = Date()
            if currentTime.timeIntervalSince(self.lastCollisionTime) > self.collisionDebounceThreshold {
                self.bounceCount += 1
                self.lastCollisionTime = currentTime
            }
        }
        
        collisionSubscription = AnyCancellable(subscription)
    }
    
    func hitBall(force: Float) {
        guard let ball = ballEntity,
              var physicsMotion = ball.components[PhysicsMotionComponent.self] else { return }
        
        let randomAngle = Float.random(in: 0...(2 * .pi))
        let forceDirection = SIMD3<Float>(
            cos(randomAngle) * force,
            force * 0.5,
            sin(randomAngle) * force
        )
        
        physicsMotion.linearVelocity += forceDirection / 1000
        
        let spin = SIMD3<Float>(
            Float.random(in: -5...5),
            Float.random(in: -5...5),
            Float.random(in: -5...5)
        )
        physicsMotion.angularVelocity = spin
        
        ball.components.set(physicsMotion)
    }
    
    func moveBall(to position: SIMD3<Float>) {
        guard let ball = ballEntity else { return }
        ball.position = position
        
        if var physicsMotion = ball.components[PhysicsMotionComponent.self] {
            physicsMotion.linearVelocity = [0, 0, 0]
            physicsMotion.angularVelocity = [0, 0, 0]
            ball.components.set(physicsMotion)
        }
    }
    
    func removeBall(from content: RealityViewContent) {
        if let ball = ballEntity {
            content.remove(ball)
            ballEntity = nil
        }
        collisionSubscription?.cancel()
    }
}