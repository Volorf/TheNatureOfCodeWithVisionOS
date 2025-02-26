//
//  ImmersiveView.swift
//  TheNatureOfCodeWithVisionOS
//
//  Created by Oleg Frolov on 26/02/2025.
//

import SwiftUI
import RealityKit

struct RandomWalker: View {
    
    @EnvironmentObject var randomWalkerModel: RandomWalkerModel

    var body: some View {
        
        RealityView { content in
            
            for step in randomWalkerModel.steps {
                let model = ModelEntity(
                    mesh: .generateSphere(radius: randomWalkerModel.radius),
                    materials: [SimpleMaterial(color: UIColor(step.color), isMetallic: false)]
                    )
                    
                model.position = SIMD3<Float>(x: step.getPosition().x, y: step.getPosition().y, z: step.getPosition().z)
                    
                content.add(model)
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    @Previewable @StateObject var randomWalkerModel: RandomWalkerModel = .init()
    RandomWalker()
        .environmentObject(randomWalkerModel)
}

struct StepData: Identifiable {
    let id: UUID = UUID()
    let color: Color
    let position: SIMD3<Int>
    let multiplier: Float
    
    func getPosition() -> SIMD3<Float> {
        var p: SIMD3<Float> = .zero
        p.x = Float(position.x) * multiplier
        p.y = Float(position.y) * multiplier
        p.z = Float(position.z) * multiplier
        return p
    }
}

class RandomWalkerModel: ObservableObject {
    let radius: Float = 0.1
    var steps: [StepData] = []
    var currentPosition: SIMD3<Int> = .zero
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
    var currentColorIndex: Int = 0
    var oldSteps: Set<SIMD3<Int>> = []
    
    init() {
        let firstStep = StepData(color: .green, position: currentPosition, multiplier: radius * 2)
        steps.append(firstStep)
        for _ in 1...10 {
            var xStep: Int = 0
            var yStep: Int = 0
            var zStep: Int = 0
            let xyzInd: Int = Int.random(in: 0..<3)
            let ranOff = Int.random(in: -1...1)
            xStep = xyzInd == 0 ? ranOff : 0
            yStep = xyzInd == 1 ? ranOff : 0
            zStep = xyzInd == 2 ? ranOff : 0
            
//            let color: Color = colors[Int.random(in: 0..<colors.count)]
            
            print("xStep: \(xStep), yStep: \(yStep), zStep: \(zStep)")
            currentPosition.x += xStep
            currentPosition.y += yStep
            currentPosition.z += zStep
            let newStep = StepData(color: getNextColor(), position: currentPosition, multiplier: radius * 2)
            
            steps.append(newStep)
        }
    }
    
    func getNextColor() -> Color {
        let index: Int = currentColorIndex % colors.count
        currentColorIndex += 1
        return colors[index]
    }
}
