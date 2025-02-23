import SwiftUI

struct EightPuzzleView: View {
    @State private var showAIExplanation = false
    @State private var solutionSteps: [String] = []
    @State private var aiThinking = false
    @State private var userMoves: [String] = []
    @State private var feedbackMessage = ""
    @State private var showFeedback = false
    @State private var showSolutionCard = false
    @State private var showSolution = false
    @Environment(\.presentationMode) var presentationMode

    let mainColor = Color(red: 0.26, green: 0.13, blue: 0.53)
    let accentColor = Color.black
    let highlightColor = Color.yellow

    @State private var puzzleState: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 0]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [mainColor, .black]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 30) {
                        Text("8-Puzzle Problem")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Goal: Arrange the tiles from 1 to 8 with the empty tile in the bottom right corner.")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(accentColor.opacity(0.7))
                            .cornerRadius(15)

                        PuzzleGridView(puzzleState: $puzzleState)

                        VStack(spacing: 10) {
                            Text("Enter your moves:")
                                .foregroundColor(.white)
                            
                            HStack {
                                ForEach(userMoves, id: \.self) { move in
                                    Text(move)
                                        .padding(8)
                                        .background(Color.white)
                                        .foregroundColor(.black)
                                        .cornerRadius(8)
                                }
                            }
                            
                            HStack {
                                ForEach(["Up", "Down", "Left", "Right"], id: \.self) { direction in
                                    Button(action: {
                                        userMoves.append(direction.lowercased())
                                    }) {
                                        Text(direction)
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(PuzzleActionButtonStyle(color: .purple))
                                }
                            }

                            HStack {
                                Button("Clear Moves") {
                                    userMoves.removeAll()
                                }
                                .buttonStyle(PuzzleActionButtonStyle(color: accentColor))
                            
                                Button("Check Solution") {
                                    checkSolution()
                                }
                                .buttonStyle(PuzzleSolveButtonStyle(color: accentColor))
                            }
                        }

                        if showFeedback {
                            Text(feedbackMessage)
                                .foregroundColor(feedbackMessage.contains("Correct") ? .green : .red)
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
                            EightPuzzle_AIExplanationSlideshow(accentColor: accentColor)
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
    }

    func checkSolution() {
        let initialState = [1, 2, 3, 4, 5, 6, 7, 8, 0]
        if isSolvable(puzzle: initialState) {
            let result = checkSolutionMoves(initialState: initialState, moves: userMoves)
            feedbackMessage = result ? "Correct! You solved the puzzle." : "Incorrect. Try again."
        } else {
            feedbackMessage = "Puzzle is not solvable."
        }
        showFeedback = true
    }

    func isSolvable(puzzle: [Int]) -> Bool {
        var inversions = 0
        let flatPuzzle = puzzle.filter { $0 != 0 }
        for i in 0..<flatPuzzle.count {
            for j in i+1..<flatPuzzle.count {
                if flatPuzzle[i] > flatPuzzle[j] {
                    inversions += 1
                }
            }
        }
        return inversions % 2 == 0
    }

    func isGoalState(_ puzzle: [Int]) -> Bool {
        return puzzle == [1, 2, 3, 4, 5, 6, 7, 8, 0]
    }

    func applyMove(_ puzzle: [Int], move: String) -> [Int] {
        var newPuzzle = puzzle
        let emptyIndex = newPuzzle.firstIndex(of: 0)!
        switch move {
        case "up" where emptyIndex > 2:
            newPuzzle.swapAt(emptyIndex, emptyIndex - 3)
        case "down" where emptyIndex < 6:
            newPuzzle.swapAt(emptyIndex, emptyIndex + 3)
        case "left" where emptyIndex % 3 != 0:
            newPuzzle.swapAt(emptyIndex, emptyIndex - 1)
        case "right" where emptyIndex % 3 != 2:
            newPuzzle.swapAt(emptyIndex, emptyIndex + 1)
        default:
            break
        }
        return newPuzzle
    }

    func checkSolutionMoves(initialState: [Int], moves: [String]) -> Bool {
        var currentState = initialState
        for move in moves {
            currentState = applyMove(currentState, move: move)
        }
        return isGoalState(currentState)
    }
}

struct PuzzleGridView: View {
    @Binding var puzzleState: [Int]

    var body: some View {
        VStack(spacing: 5) {
            ForEach(0..<3) { row in
                HStack(spacing: 5) {
                    ForEach(0..<3) { col in
                        let index = row * 3 + col
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(puzzleState[index] == 0 ? Color.clear : Color.white)
                                .frame(width: 60, height: 60)
                            if puzzleState[index] != 0 {
                                Text("\(puzzleState[index])")
                                    .font(.title)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.3))
        .cornerRadius(15)
    }
}

struct PuzzleActionButtonStyle: ButtonStyle {
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct PuzzleSolveButtonStyle: ButtonStyle {
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct EightPuzzle_AIExplanationSlideshow: View {
    let accentColor: Color
    @State private var currentSlide = 0
    let slides = [
        "Slide 1: Introduction to 8-Puzzle Problem",
        "Slide 2: Search Algorithms for 8-Puzzle",
        "Slide 3: Heuristics in 8-Puzzle Solving",
        "Slide 4: Complexity and Optimality"
    ]

    var body: some View {
        VStack {
            Text(slides[currentSlide])
                .padding()
                .frame(height: 200)
                .background(Color.white)
                .cornerRadius(10)
                .padding()

            HStack {
                Button(action: {
                    withAnimation {
                        currentSlide = (currentSlide - 1 + slides.count) % slides.count
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }

                Spacer()

                Button(action: {
                    withAnimation {
                        currentSlide = (currentSlide + 1) % slides.count
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
            }
            .padding()
        }
        .background(accentColor)
        .cornerRadius(15)
    }
}
