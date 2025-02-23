import SwiftUI

struct MissionariesAndCannibalsView: View {
    @State private var showAIExplanation = false
    @State private var showSolutionCard = false
    @State private var feedbackMessage = ""
    @State private var showFeedback = false
    @State private var gameState = GameState()
    @Environment(\.presentationMode) var presentationMode

    let mainColor = Color(red: 0.26, green: 0.13, blue: 0.53)
    let accentColor = Color.black
    let highlightColor = Color.yellow

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [mainColor, .black]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 30) {
                        Text("Missionaries and Cannibals")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Goal: Move all missionaries and cannibals to the other side without the cannibals outnumbering the missionaries on either side.")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(accentColor.opacity(0.7))
                            .cornerRadius(15)

                        HStack {
                            Button(action: {
                                resetGame()
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18))
                                    .padding(10)
                                    .background(accentColor)
                                    .cornerRadius(100)
                            }
                            .buttonStyle(MCActionButtonStyle(color: accentColor))
                            
                            Spacer()
                            
                            Button(action: {
                                showSolutionCard = true
                            }) {
                                Image(systemName: "lightbulb")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18))
                                    .padding(10)
                                    .background(accentColor)
                                    .cornerRadius(100)
                            }
                            .buttonStyle(MCActionButtonStyle(color: accentColor))
                        }
                        
                        GameBoardView(gameState: $gameState)
                            .frame(height: 300)

                        VStack(spacing: 10) {
                            Text("Move missionaries and cannibals:")
                                .foregroundColor(.white)
                            
                            HStack {
                                Button("1 Missionary") {
                                    movePeople(missionaries: 1, cannibals: 0)
                                }
                                .buttonStyle(MCActionButtonStyle(color: .green))
                                
                                Button("1 Cannibal") {
                                    movePeople(missionaries: 0, cannibals: 1)
                                }
                                .buttonStyle(MCActionButtonStyle(color: .red))
                            }
                            
                            HStack {
                                Button("2 Missionaries") {
                                    movePeople(missionaries: 2, cannibals: 0)
                                }
                                .buttonStyle(MCActionButtonStyle(color: .green))
                                
                                Button("2 Cannibals") {
                                    movePeople(missionaries: 0, cannibals: 2)
                                }
                                .buttonStyle(MCActionButtonStyle(color: .red))
                            }
                            
                            Button("1 Missionary, 1 Cannibal") {
                                movePeople(missionaries: 1, cannibals: 1)
                            }
                            .buttonStyle(MCActionButtonStyle(color: .purple))
                        }

                        if showFeedback {
                            Text(feedbackMessage)
                                .foregroundColor(feedbackMessage.contains("Win") ? .green : .red)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                        }

                        Button(action: {
                            withAnimation {
                                showAIExplanation.toggle()
                            }
                        }) {
                            Text(showAIExplanation ? "Hide AI Explanation" : "Show AI Explanation")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .padding()
                                .background(accentColor)
                                .cornerRadius(15)
                        }

                        if showAIExplanation {
                            MC_AIExplanationSlideshow(accentColor: accentColor)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.white)
                .font(.system(size: 24, weight: .bold))
                .padding()
                .background(accentColor)
                .clipShape(Circle())
        })
        .sheet(isPresented: $showSolutionCard) {
            MCSolutionView()
                .background(Color.white.opacity(0.2))
                .cornerRadius(15)
        }
    }

    func movePeople(missionaries: Int, cannibals: Int) {
        if gameState.isValidMove(missionaries: missionaries, cannibals: cannibals) {
            gameState.movePeople(missionaries: missionaries, cannibals: cannibals)
            checkGameStatus()
        } else {
            feedbackMessage = "Invalid move. Try again."
            showFeedback = true
        }
    }

    func checkGameStatus() {
        if gameState.isGameOver() {
            feedbackMessage = "Game Over! Cannibals ate the missionaries."
            showFeedback = true
        } else if gameState.isGameWon() {
            feedbackMessage = "Congratulations! You've won the game!"
            showFeedback = true
        } else {
            showFeedback = false
        }
    }

    func resetGame() {
        gameState = GameState()
        showFeedback = false
    }
}

struct GameState {
    var leftBank: (missionaries: Int, cannibals: Int) = (3, 3)
    var rightBank: (missionaries: Int, cannibals: Int) = (0, 0)
    var boatPosition: BankSide = .left

    enum BankSide {
        case left, right
    }

    mutating func movePeople(missionaries: Int, cannibals: Int) {
        if boatPosition == .left {
            leftBank.missionaries -= missionaries
            leftBank.cannibals -= cannibals
            rightBank.missionaries += missionaries
            rightBank.cannibals += cannibals
        } else {
            leftBank.missionaries += missionaries
            leftBank.cannibals += cannibals
            rightBank.missionaries -= missionaries
            rightBank.cannibals -= cannibals
        }
        boatPosition = boatPosition == .left ? .right : .left
    }

    func isValidMove(missionaries: Int, cannibals: Int) -> Bool {
        let totalPeople = missionaries + cannibals
        if totalPeople < 1 || totalPeople > 2 {
            return false
        }

        let sourceSide = boatPosition == .left ? leftBank : rightBank
        if missionaries > sourceSide.missionaries || cannibals > sourceSide.cannibals {
            return false
        }

        let newLeftMissionaries = boatPosition == .left ? leftBank.missionaries - missionaries : leftBank.missionaries + missionaries
        let newLeftCannibals = boatPosition == .left ? leftBank.cannibals - cannibals : leftBank.cannibals + cannibals
        let newRightMissionaries = boatPosition == .left ? rightBank.missionaries + missionaries : rightBank.missionaries - missionaries
        let newRightCannibals = boatPosition == .left ? rightBank.cannibals + cannibals : rightBank.cannibals - cannibals

        return (newLeftMissionaries >= newLeftCannibals || newLeftMissionaries == 0) &&
               (newRightMissionaries >= newRightCannibals || newRightMissionaries == 0)
    }

    func isGameOver() -> Bool {
        return (leftBank.cannibals > leftBank.missionaries && leftBank.missionaries > 0) ||
               (rightBank.cannibals > rightBank.missionaries && rightBank.missionaries > 0)
    }

    func isGameWon() -> Bool {
        return rightBank.missionaries == 3 && rightBank.cannibals == 3
    }
}

struct GameBoardView: View {
    @Binding var gameState: GameState

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // River
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: geometry.size.width, height: 100)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                // Left Bank
                BankView(missionaries: gameState.leftBank.missionaries, cannibals: gameState.leftBank.cannibals)
                    .position(x: geometry.size.width * 0.25, y: geometry.size.height / 2)

                // Right Bank
                BankView(missionaries: gameState.rightBank.missionaries, cannibals: gameState.rightBank.cannibals)
                    .position(x: geometry.size.width * 0.75, y: geometry.size.height / 2)

                // Boat
                BoatView()
                    .position(x: gameState.boatPosition == .left ? geometry.size.width * 0.35 : geometry.size.width * 0.65,
                              y: geometry.size.height / 2)
            }
        }
    }
}

struct BankView: View {
    let missionaries: Int
    let cannibals: Int

    var body: some View {
        VStack {
            Text("M: \(missionaries)")
                .foregroundColor(.white)
            Text("C: \(cannibals)")
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.gray.opacity(0.5))
        .cornerRadius(10)
    }
}

struct BoatView: View {
    var body: some View {
        Image(systemName: "ferry")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 50, height: 50)
            .foregroundColor(.white)
    }
}

struct MC_AIExplanationSlideshow: View {
    let accentColor: Color
    @State private var currentSlide = 0

    let slides: [MCAISlide] = [
        MCAISlide(title: "AI Algorithm: Breadth-First Search (BFS)",
              content: "The AI uses Breadth-First Search to find the optimal solution. It explores all possible moves at each step before moving to the next level."),
        MCAISlide(title: "State Representation",
              content: "Each state is represented as (left_missionaries, left_cannibals, boat_position). The goal is to reach (0, 0, 0) from (3, 3, 1)."),
        MCAISlide(title: "Valid Moves",
              content: "The AI considers all valid moves: (1,0), (2,0), (0,1), (0,2), (1,1). It ensures no illegal states are reached."),
        MCAISlide(title: "Exploring the State Space",
              content: "BFS explores the state space level by level, ensuring the shortest solution is found first."),
        MCAISlide(title: "Backtracking",
              content: "Once the goal state is reached, the AI backtracks to construct the solution path."),
        MCAISlide(title: "Optimal Solution",
              content: "The AI finds the optimal solution with the minimum number of moves, typically 11 steps for the standard problem.")
    ]

    var body: some View {
        VStack {
            Text(slides[currentSlide].title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 5)

            ScrollView {
                Text(slides[currentSlide].content)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal)

            HStack {
                Button(action: {
                    if currentSlide > 0 {
                        currentSlide -= 1
                    }
                }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .stroke(accentColor, lineWidth: 2)
                        )
                }
                .disabled(currentSlide == 0)

                Spacer()

                Text("\(currentSlide + 1) / \(slides.count)")
                    .font(.subheadline)
                    .foregroundColor(.white)

                Spacer()

                Button(action: {
                    if currentSlide < slides.count - 1 {
                        currentSlide += 1
                    }
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .stroke(accentColor, lineWidth: 2)
                        )
                }
                .disabled(currentSlide == slides.count - 1)
            }
            .padding()
        }
        .padding()
        .background(accentColor.opacity(0.2))
        .cornerRadius(20)
    }
}

struct MCAISlide {
    let title: String
    let content: String
}

struct MCActionButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct MCSolutionView: View {
    let solution = [
        "Move 2 cannibals to the right bank",
        "Return 1 cannibal to the left bank",
        "Move 2 cannibals to the right bank",
        "Return 1 cannibal to the left bank",
        "Move 2 missionaries to the right bank",
        "Return 1 missionary and 1 cannibal to the left bank",
        "Move 2 missionaries to the right bank",
        "Return 1 cannibal to the left bank",
        "Move 2 cannibals to the right bank",
        "Return 1 cannibal to the left bank",
        "Move
