import RealityKit
import SwiftUI
import Combine

@MainActor
class PhysicsManager: ObservableObject {
    static let worldScale: Float = 100.0
    
    @Published var bounceCount: Int = 0
    @Published var ballEntity: Entity?
    var physicsRoot: Entity?
    
    private var collisionSubscription: EventSubscription?
    private var lastCollisionTime: Date = .distantPast
    private let collisionDebounceThreshold: TimeInterval = 0.1
    
    struct PhysicsParams {
        var staticFriction: Float = 0.5
        var dynamicFriction: Float = 0.5
        var linearDamping: Float = 0.0
        var angularDamping: Float = 0.0
    }
    
    func dropBall(
        in content: RealityViewContent,
        at position: SIMD3<Float>,
        radius: Float,
        physicsParams: PhysicsParams
    ) {
        removeBall(from: content)
        bounceCount = 0
        
        guard let physicsRoot = physicsRoot else {
            print("Physics root not initialized")
            return
        }
        
        let ball = createBall(radius: radius, physicsParams: physicsParams)
        ball.position = position * PhysicsManager.worldScale
        
        ball.setParent(physicsRoot)
        ballEntity = ball
        
        setupCollisionDetection(for: ball, in: content)
    }
    
    private func createBall(radius: Float, physicsParams: PhysicsParams) -> ModelEntity {
        let scaledRadius = radius * PhysicsManager.worldScale
        let ballShape = ShapeResource.generateSphere(radius: scaledRadius)
        
        let ball = ModelEntity(
            mesh: MeshResource(shape: ballShape),
            materials: [SimpleMaterial(color: .systemBlue, isMetallic: true)]
        )
        
        ball.components.set(CollisionComponent(shapes: [ballShape], isStatic: false))
        
        var physicsBody = PhysicsBodyComponent(
            massProperties: .init(mass: 0.1),
            material: .generate(
                staticFriction: physicsParams.staticFriction,
                dynamicFriction: physicsParams.dynamicFriction,
                restitution: 1.0
            ),
            mode: .dynamic
        )
        
        physicsBody.linearDamping = physicsParams.linearDamping
        physicsBody.angularDamping = physicsParams.angularDamping
        
        ball.components.set(physicsBody)
        
        let physicsMotion = PhysicsMotionComponent(
            linearVelocity: [0, 0, 0],
            angularVelocity: [0, 0, 0]
        )
        
        ball.components.set(physicsMotion)
        
        return ball
    }
    
    private func setupCollisionDetection(for ball: Entity, in content: RealityViewContent) {
        collisionSubscription?.cancel()
        
        collisionSubscription = content.subscribe(
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
    }
    
    func hitBall(force: Float) {
        guard let ball = ballEntity,
              var physicsMotion = ball.components[PhysicsMotionComponent.self] else { return }
        
        let scaledForce = force * PhysicsManager.worldScale
        let randomAngle = Float.random(in: 0...(2 * .pi))
        let forceDirection = SIMD3<Float>(
            cos(randomAngle) * scaledForce,
            scaledForce * 0.5,
            sin(randomAngle) * scaledForce
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
        ball.position = position * PhysicsManager.worldScale
        
        if var physicsMotion = ball.components[PhysicsMotionComponent.self] {
            physicsMotion.linearVelocity = [0, 0, 0]
            physicsMotion.angularVelocity = [0, 0, 0]
            ball.components.set(physicsMotion)
        }
    }
    
    func removeBall(from content: RealityViewContent) {
        if let ball = ballEntity {
            ball.removeFromParent()
            ballEntity = nil
        }
        collisionSubscription?.cancel()
    }
    
    func setupPhysicsScene(_ content: RealityViewContent) {
        var physicsSimulation = PhysicsSimulationComponent()
        physicsSimulation.gravity = .init(x: 0.0, y: -9.8 * PhysicsManager.worldScale, z: 0.0)
        
        let physicsRoot = Entity()
        physicsRoot.components.set(physicsSimulation)
        physicsRoot.transform.scale = SIMD3<Float>(repeating: 1.0 / PhysicsManager.worldScale)
        physicsRoot.name = "Physics Root"
        
        content.add(physicsRoot)
        self.physicsRoot = physicsRoot
        
        let ground = ModelEntity(
            mesh: .generateBox(width: 0.5 * PhysicsManager.worldScale, height: 0.02 * PhysicsManager.worldScale, depth: 0.5 * PhysicsManager.worldScale),
            materials: [SimpleMaterial(color: .gray, isMetallic: false)]
        )
        ground.position = [0, -0.01 * PhysicsManager.worldScale, 0]
        
        let groundPhysics = PhysicsBodyComponent(
            massProperties: .default,
            material: .generate(staticFriction: 0.8, dynamicFriction: 0.5, restitution: 1.0),
            mode: .static
        )
        ground.components.set(groundPhysics)
        ground.generateCollisionShapes(recursive: false)
        
        ground.setParent(physicsRoot)
        
        let light = DirectionalLight()
        light.light.intensity = 5000
        light.orientation = simd_quatf(angle: -.pi / 4, axis: [1, 0, 0])
        content.add(light)
    }
}
