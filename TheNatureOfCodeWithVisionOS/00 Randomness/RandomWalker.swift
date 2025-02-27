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
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    let numberIterations: Int = 100
    @State private var counter: Int = 0

    var body: some View {
        
        RealityView { content in
            } update: { content in
                for model in randomWalkerModel.modelEntities {
                    content.add(model)
            }
        }
        .onReceive(timer) { time in
            if counter == randomWalkerModel.modelEntities.count {
                timer.upstream.connect().cancel()
            } else {
                randomWalkerModel.modelEntities[counter].scale = SIMD3<Float>(x: 1.0, y: 1.0, z: 1.0)
                counter += 1
                print(counter)
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
    
    let radius: Float = 0.025
    let limitBox: SIMD3<Int> = SIMD3<Int>(20, 20, 20)
    @Published var steps: [StepData] = []
    var currentPosition: SIMD3<Int> = SIMD3<Int>(0, 0, 0)
//    let colors: [Color] = [Color("Red"), Color("Orange"), Color("Yellow"), Color("Lime"), Color("Green"), Color("Teal"), Color("LightBlue"), Color("Blue"), Color("DarkBlue"), Color("Purple"), Color("Magenta"), Color("Pink")]
    
    var colors: [Color] = []
    var currentColorIndex: Int = 0
    var oldSteps: Set<SIMD3<Int>> = []
    let numberOfIterations: Int = 400
    var modelEntities: [ModelEntity] = []
    
    func generateColors(num: Int) -> [Color] {
        var colors: [Color] = []
        for i in 0...num {
            let h = Double(i) / Double(num)
//            print("hue: \(h)")
            let c = Color(hue: h, saturation: 1, brightness: 1)
            colors.append(c)
        }
        return colors
    }
    
    init() {
        
        colors = generateColors(num: 96)
        
        for _ in 0...numberOfIterations {
            
            currentPosition = getNextPosition(curPos: currentPosition)
            if oldSteps.contains(currentPosition) {
                break
            }
               
            oldSteps.insert(currentPosition)
            
            let newStep = StepData(color: getNextColor(), position: currentPosition, multiplier: radius * 2)
            
            steps.append(newStep)
            
            let model = ModelEntity(
//                mesh: .generateSphere(radius: radius)
                mesh: .generateBox(size: radius * 2, cornerRadius: radius / 8),
                materials: [SimpleMaterial(color: UIColor(newStep.color), isMetallic: false)])
                
            model.position = SIMD3<Float>(x: newStep.getPosition().x, y: newStep.getPosition().y, z: newStep.getPosition().z)
            model.scale = SIMD3<Float>(x: 0.0, y: 0.0, z: 0.0)
            modelEntities.append(model)
        }
    }
    
    func getNextColor() -> Color {
        let index: Int = currentColorIndex % colors.count
        currentColorIndex += 1
        return colors[index]
    }
    
    func getNextPosition(curPos: SIMD3<Int>) -> SIMD3<Int> {
        let newPos: [SIMD3<Int>] = getNextStepPositions(curPos: currentPosition)
        
        for pos in newPos {
            if (!oldSteps.contains(pos) &&
                pos.x <= limitBox.x &&
                pos.x >= -limitBox.x &&
                pos.y <= limitBox.y &&
                pos.y >= -limitBox.y &&
                pos.z <= limitBox.z &&
                pos.z >= -limitBox.z) {
                return pos;
            }
        }
        return curPos
    }
    
    func getNextStepPositions(curPos: SIMD3<Int>) -> [SIMD3<Int>] {
        let nextUp: SIMD3<Int> = curPos &+ SIMD3<Int>(0, 1, 0)
        let nextDown: SIMD3<Int> = curPos &+ SIMD3<Int>(0, -1, 0)
        let nextLeft: SIMD3<Int> = curPos &+ SIMD3<Int>(-1, 0, 0)
        let nextRight: SIMD3<Int> = curPos &+ SIMD3<Int>(1, 0, 0)
        let nextBack: SIMD3<Int> = curPos &+ SIMD3<Int>(0, 0, -1)
        let nextFront: SIMD3<Int> = curPos &+ SIMD3<Int>(0, 0, 1)
        
        let options: [SIMD3<Int>] = [nextUp, nextDown, nextLeft, nextRight, nextBack, nextFront]
        
        return options.shuffled()
    }
}
