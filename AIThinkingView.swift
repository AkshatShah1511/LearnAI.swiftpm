struct AIThinkingView: View {
    @Binding var gameTree: [GameState]
    @State private var currentDepth: Int = 0
    
    var body: some View {
        VStack {
            Text("AI Thinking Process")
                .font(.headline)
            
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 20) {
                    ForEach(0..<gameTree.count, id: \.self) { depth in
                        VStack {
                            Text("Depth \(depth)")
                                .font(.subheadline)
                            ForEach(gameTree[depth].possibleMoves, id: \.self) { move in
                                BoardView(board: move.board, size: 50)
                                    .overlay(
                                        Text(String(format: "%.2f", move.score))
                                            .font(.caption)
                                            .foregroundColor(move.score > 0 ? .green : .red)
                                    )
                            }
                        }
                        .opacity(depth <= currentDepth ? 1 : 0.3)
                    }
                }
            }
            .frame(height: 300)
            
            Button("Step Through") {
                withAnimation {
                    currentDepth = min(currentDepth + 1, gameTree.count - 1)
                }
            }
        }
    }
}

struct GameState {
    var possibleMoves: [Move]
}

struct Move {
    var board: [[String]]
    var score: Float
}
