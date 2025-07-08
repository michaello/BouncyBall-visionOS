# BouncyBall - RealityKit Physics Demo for visionOS

A sample visionOS app demonstrating RealityKit physics with adjustable parameters, created as a reference for Apple Developer Forums discussions about bouncing ball physics.

## Overview

This project showcases how to implement realistic ball physics in RealityKit for Vision Pro, addressing common issues with energy loss during bounces. It provides real-time control over physics parameters through an interactive ornament interface.

## Features

- **RealityKit Physics**: Pure RealityKit physics implementation with configurable parameters
- **Interactive Controls**: Ornament view with sliders for real-time physics adjustments
- **Physics Parameters**:
  - Drop height (0.1-2.0m)
  - Ball radius (0.02-0.2m)
  - Hit force (10-100N)
  - Linear damping (0-1)
  - Angular damping (0-1)
  - Static friction (0-1)
  - Dynamic friction (0-1)
- **Bounce Counter**: Tracks number of collisions with ground plane
- **Ball Interaction**: Drag to move, button to apply random force

## Key Physics Settings for Maximum Bounce

Based on Apple Developer Forum discussions, the following settings achieve near-perfect bouncing:

1. **Restitution = 1.0** on both ball and ground (perfect elasticity)
2. **Linear/Angular Damping = 0.0** (no energy loss from air resistance)
3. **Mass = 0.1kg** (realistic for stability)

## Apple Developer Forum Reference

This project was created to demonstrate solutions discussed in the Apple Developer Forums thread about achieving natural bouncing behavior in RealityKit:
- [Bouncy ball in RealityKit - game](https://developer.apple.com/forums/thread/765530)

## Requirements

- Xcode 16.0 or later
- visionOS 2.0 or later
- Apple Vision Pro device or simulator

## Installation

1. Clone the repository
2. Open `BouncyBall.xcodeproj` in Xcode
3. Build and run on Vision Pro device or simulator

## Technical Details

The app uses:
- `PhysicsBodyComponent` with configurable damping properties
- `PhysicsMotionComponent` for velocity control
- `CollisionComponent` for bounce detection
- Event-driven collision counting with debouncing

## License

This sample code is provided as-is for educational purposes and Apple Developer Forum reference.