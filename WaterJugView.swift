import SwiftUI

struct WaterJugView: View {
    // State variables for jug levels and target
    @State private var jug1Level: Int = 0
    @State private var jug2Level: Int = 0
    @State private var targetAmount: Int = 4 // Example Target
    @State private var jug1Capacity: Int = 5 // Example Capacity
    @State private var jug2Capacity: Int = 3 // Example Capacity

    @State private var gameOver = false // Probably not needed, but keeping consistent
    @State private var winner: String? = nil // Probably not needed, but keeping consistent
    @State private var aiThinking = false // Adapt for any "solving" animation

    @State private var showSolutionExplanation = false // Adapt Minimax Explanation
    @State private var solutionSteps: [String] = [] // Array to hold the solution steps
    @Environment(\.presentationMode) var presentationMode

    let mainColor = Color(red: 0.26, green: 0.13, blue: 0.53) // Equivalent to #432287
    let accentColor = Color.black

    var body: some View {
        NavigationStack{
            ZStack {
                mainColor.edgesIgnoringSafeArea(.all)

                VStack {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .bold))
                                .padding()
                                .background(accentColor)
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    ScrollView {
                        VStack(spacing: 30) {
                            Text("Water Jug Problem")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)


                            HStack {
                                JugView(level: jug1Level, capacity: jug1Capacity)
                                JugView(level: jug2Level, capacity: jug2Capacity)

                            }
                            .padding()
                            .background(accentColor.opacity(0.1))
                            .cornerRadius(20)
                            .shadow(color: accentColor.opacity(0.2), radius: 10, x: 0, y: 5)

                            Text("Target Amount: \(targetAmount)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            HStack {
                                Button("Fill Jug 1") { fillJug1() }
                                    .buttonStyle(NeonButtonStyle(color: accentColor))
                                Button("Fill Jug 2") { fillJug2() }
                                    .buttonStyle(NeonButtonStyle(color: accentColor))
                            }

                            HStack {
                                Button("Empty Jug 1") { emptyJug1() }
                                    .buttonStyle(NeonButtonStyle(color: accentColor))
                                Button("Empty Jug 2") { emptyJug2() }
                                    .buttonStyle(NeonButtonStyle(color: accentColor))
                            }

                            HStack {
                                Button("Pour 1 -> 2") { pour1to2() }
                                    .buttonStyle(NeonButtonStyle(color: accentColor))
                                Button("Pour 2 -> 1") { pour2to1() }
                                    .buttonStyle(NeonButtonStyle(color: accentColor))
                            }

                            if aiThinking {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                            }

                            Button(action: {
                                withAnimation {
                                    showSolutionExplanation.toggle()
                                }
                            }) {
                                Text(showSolutionExplanation ? "Hide Solution Steps" : "Show Solution Steps")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(accentColor)
                                    .cornerRadius(15)
                            }

                            if showSolutionExplanation {
                                SolutionExplanationView(steps: solutionSteps, accentColor: accentColor)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            }

                            Button("Solve") {
                                solve()
                            }
                            .buttonStyle(NeonButtonStyle(color: accentColor))
                        }
                        .padding()
                    }
                }
            }
        }.navigationBarBackButtonHidden()
    }

    // Water Jug Logic - Implement these functions
    func fillJug1() {
        jug1Level = jug1Capacity
    }

    func fillJug2() {
        jug2Level = jug2Capacity
    }

    func emptyJug1() {
        jug1Level = 0
    }

    func emptyJug2() {
        jug2Level = 0
    }

    func pour1to2() {
        let amountToPour = min(jug1Level, jug2Capacity - jug2Level)
        jug1Level -= amountToPour
        jug2Level += amountToPour
    }

    func pour2to1() {
        let amountToPour = min(jug2Level, jug1Capacity - jug1Level)
        jug2Level -= amountToPour
        jug1Level += amountToPour
    }

    func solve() {
            //Implement your solving logic here
            solutionSteps = WaterJugSolver.solve(jug1Capacity: jug1Capacity, jug2Capacity: jug2Capacity, target: targetAmount, jug1Level: jug1Level, jug2Level: jug2Level)
            aiThinking = false

    }


}

struct JugView: View {
    let level: Int
    let capacity: Int

    var body: some View {
        VStack {
            Text("Jug: \(level)/\(capacity)")
                .font(.headline)
                .foregroundColor(.white)
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .fill(Color.blue.opacity(0.3)) // Jug outline
                        .border(Color.white, width: 2)
                        .frame(width: geometry.size.width, height: geometry.size.height)

                    Rectangle()
                        .fill(Color.blue) // Water level
                        .frame(width: geometry.size.width, height: CGFloat(level) / CGFloat(capacity) * geometry.size.height)
                }
            }
            .frame(width: 100, height: 200) // Adjust size as needed
        }
    }
}

struct SolutionExplanationView: View {
    let steps: [String]
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Solution Steps")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            if steps.isEmpty {
                Text("No solution steps yet.")
                    .foregroundColor(.white)
            } else {
                ForEach(steps, id: \.self) { step in
                    HStack(alignment: .top) {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(accentColor)
                            .font(.system(size: 12))
                            .padding(.top, 5)
                        Text(step)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
        .background(accentColor.opacity(0.2))
        .cornerRadius(20)
    }
}

struct NeonButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(color)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .shadow(color: color.opacity(0.5), radius: 10, x: 0, y: 5)
    }
}


struct GridView: View {  // This component is no longer needed
    @Binding var board: [String]
    let action: (Int) -> Void

    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<3) { row in
                HStack(spacing: 10) {
                    ForEach(0..<3) { col in
                        let index = row * 3 + col
                        Button(action: { action(index) }) {
                            Text(board[index])
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .frame(width: 80, height: 80)
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                    }
                }
            }
        }
    }
}

struct WaterJugSolver {

    static func solve(jug1Capacity: Int, jug2Capacity: Int, target: Int, jug1Level: Int, jug2Level: Int) -> [String] {
            var queue: [(Int, Int, [String])] = [(jug1Level, jug2Level, [])] // (jug1, jug2, steps)
            var visited: Set<String> = ["\(jug1Level),\(jug2Level)"]
            
            while !queue.isEmpty {
                let (currentJug1, currentJug2, currentSteps) = queue.removeFirst()
                
                if currentJug1 == target || currentJug2 == target {
                    return currentSteps
                }
                
                // Define possible actions
                let actions: [(String, (Int, Int))] = [
                    ("Fill Jug 1", (jug1Capacity, currentJug2)),
                    ("Fill Jug 2", (currentJug1, jug2Capacity)),
                    ("Empty Jug 1", (0, currentJug2)),
                    ("Empty Jug 2", (currentJug1, 0)),
                    ("Pour Jug 1 into Jug 2", (max(0, currentJug1 - (jug2Capacity - currentJug2)), min(jug2Capacity, currentJug2 + currentJug1))),
                    ("Pour Jug 2 into Jug 1", (min(jug1Capacity, currentJug1 + currentJug2), max(0, currentJug2 - (jug1Capacity - currentJug1))))
                ]
                
                for (action, (nextJug1, nextJug2)) in actions {
                    let stateKey = "\(nextJug1),\(nextJug2)"
                    if !visited.contains(stateKey) {
                        visited.insert(stateKey)
                        let newSteps = currentSteps + ["\(action): Jug 1 = \(nextJug1), Jug 2 = \(nextJug2)"]
                        queue.append((nextJug1, nextJug2, newSteps))
                    }
                }
            }
            
            return ["No solution found."]
        }
}

