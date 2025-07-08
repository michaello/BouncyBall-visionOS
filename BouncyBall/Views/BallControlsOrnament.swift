import SwiftUI
import RealityKit

struct BallControlsOrnament: View {
    @Bindable var appModel: AppModel
    
    @Binding var dropHeight: Float
    @Binding var ballRadius: Float
    @Binding var hitForce: Float
    @Binding var linearDamping: Float
    @Binding var angularDamping: Float
    @Binding var staticFriction: Float
    @Binding var dynamicFriction: Float
    
    let onDropBall: () -> Void
    let onHitBall: () -> Void
    
    @State private var debounceTask: Task<Void, Never>?
    
    var body: some View {
        VStack(spacing: 20) {
            titleSection
            actionButtons
            bounceCounter
            Divider()
            physicsSliders
        }
        .padding(30)
        .frame(width: 300)
    }
    
    private var titleSection: some View {
        Text("Ball Controls")
            .font(.largeTitle)
            .fontWeight(.bold)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 20) {
            Button(action: onDropBall) {
                Label("Drop Ball", systemImage: "arrow.down.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            
            Button(action: onHitBall) {
                Label("Hit Ball", systemImage: "hand.tap.fill")
            }
            .buttonStyle(.bordered)
            .disabled(appModel.physicsManager.ballEntity == nil)
        }
    }
    
    private var bounceCounter: some View {
        VStack(spacing: 8) {
            Text("Bounce Count")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("\(appModel.physicsManager.bounceCount)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
        }
        .animation(.spring(response: 0.3), value: appModel.physicsManager.bounceCount)
    }
    
    private var physicsSliders: some View {
        Group {
            VStack(spacing: 4) {
                Text("Drop Height: \(String(format: "%.2f", dropHeight))m")
                Slider(value: $dropHeight, in: 0.1...2.0, step: 0.05)
            }
            
            VStack(spacing: 4) {
                Text("Ball Radius: \(String(format: "%.2f", ballRadius))m")
                Slider(value: $ballRadius, in: 0.02...0.2, step: 0.01)
            }
            
            VStack(spacing: 4) {
                Text("Hit Force: \(String(format: "%.1f", hitForce))N")
                Slider(value: $hitForce, in: 10...100, step: 5)
            }
            
            VStack(spacing: 4) {
                Text("Linear Damping: \(String(format: "%.2f", linearDamping))")
                Slider(value: $linearDamping, in: 0...1, step: 0.05)
                    .onChange(of: linearDamping) { _, _ in
                        debounceAndDropBall()
                    }
            }
            
            VStack(spacing: 4) {
                Text("Angular Damping: \(String(format: "%.2f", angularDamping))")
                Slider(value: $angularDamping, in: 0...1, step: 0.05)
                    .onChange(of: angularDamping) { _, _ in
                        debounceAndDropBall()
                    }
            }
            
            VStack(spacing: 4) {
                Text("Static Friction: \(String(format: "%.2f", staticFriction))")
                Slider(value: $staticFriction, in: 0...1, step: 0.05)
                    .onChange(of: staticFriction) { _, _ in
                        debounceAndDropBall()
                    }
            }
            
            VStack(spacing: 4) {
                Text("Dynamic Friction: \(String(format: "%.2f", dynamicFriction))")
                Slider(value: $dynamicFriction, in: 0...1, step: 0.05)
                    .onChange(of: dynamicFriction) { _, _ in
                        debounceAndDropBall()
                    }
            }
        }
        .font(.headline)
        .frame(width: 200)
    }
    
    private func debounceAndDropBall() {
        debounceTask?.cancel()
        debounceTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(200))
                onDropBall()
            } catch {
                // Task was cancelled
            }
        }
    }
}