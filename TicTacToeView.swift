import SwiftUI

struct TicTacToeView: View {
    @State private var board = Array(repeating: "", count: 9)
    @State private var currentPlayer = "X"
    @State private var aiThinking = false
    @State private var gameOver = false
    @State private var winner: String?
    
    var body: some View {
        VStack {
            Text("Tic-Tac-Toe with AI")
                .font(.title)
                .padding()
            
            GridView(board: $board) { index in
                if !aiThinking && !gameOver {
                    makeMove(at: index)
                }
            }
            
            if aiThinking {
                Text("AI is thinking...")
                    .font(.headline)
                    .padding()
            }
            
            if gameOver {
                Text(winner == nil ? "It's a draw!" : "Winner: \(winner!)")
                    .font(.headline)
                    .padding()
                
                Button("Play Again") {
                    resetGame()
                }
                .padding()
            }
        }
    }
    
    func makeMove(at index: Int) {
        guard board[index].isEmpty else { return }
        
        board[index] = currentPlayer
        
        if checkForWinner() {
            gameOver = true
            winner = currentPlayer
        } else if board.allSatisfy({ !$0.isEmpty }) {
            gameOver = true
        } else {
            currentPlayer = "O"
            aiThinking = true
            
            // Simulate AI thinking
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                aiMove()
                aiThinking = false
                currentPlayer = "X"
                
                if checkForWinner() {
                    gameOver = true
                    winner = "O"
                } else if board.allSatisfy({ !$0.isEmpty }) {
                    gameOver = true
                }
            }
        }
    }
    
    func aiMove() {
        // Implement minimax algorithm here
        // For now, just choose a random empty square
        let emptySquares = board.indices.filter { board[$0].isEmpty }
        if let aiMove = emptySquares.randomElement() {
            board[aiMove] = "O"
        }
    }
    
    func checkForWinner() -> Bool {
        // Implement win checking logic
        // For brevity, this is omitted in this example
        return false
    }
    
    func resetGame() {
        board = Array(repeating: "", count: 9)
        currentPlayer = "X"
        aiThinking = false
        gameOver = false
        winner = nil
    }
}

struct GridView: View {
    @Binding var board: [String]
    let action: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 5) {
            ForEach(0..<3) { row in
                HStack(spacing: 5) {
                    ForEach(0..<3) { col in
                        let index = row * 3 + col
                        Button(action: { action(index) }) {
                            Text(board[index])
                                .font(.system(size: 60))
                                .frame(width: 80, height: 80)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
    }
}
