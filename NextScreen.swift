import SwiftUI

struct NextScreen: View {
    @State private var offset: CGFloat = 0
    @State private var currentIndex: Int = 1
    @State private var showFlashcards: Bool = false
    // Added state for selected AI Problem
    @State private var selectedAIProblem: String? = nil

    let narrativeSteps: [NarrativeStep] = [
        NarrativeStep(title: "What is AI?", description: "AI stands for Artificial Intelligence. It's the science of making machines smart!", icon: "brain"),
        NarrativeStep(title: "How Does AI Work?", description: "AI uses algorithms and data to learn patterns and make decisions.", icon: "gear"),
        NarrativeStep(title: "Examples of AI in Real Life", description: "AI powers virtual assistants, self-driving cars, and even your favorite recommendations!", icon: "car"),
        NarrativeStep(title: "AI in Medicine", description: "AI helps doctors diagnose diseases faster and more accurately.", icon: "stethoscope"),
        NarrativeStep(title: "AI in Games", description: "AI is used in games to create smart opponents and enhance gameplay.", icon: "gamecontroller"),
        NarrativeStep(title: "Let's Solve a Problem with AI!", description: "Ready to dive in? Let's explore how AI can solve real-world problems.", icon: "lightbulb")
    ]

    let flashcards: [Flashcard] = [
        Flashcard(title: "AI Definition", description: "AI mimics human intelligence in machines."),
        Flashcard(title: "Machine Learning", description: "A subset of AI that uses data to learn."),
        Flashcard(title: "Neural Networks", description: "Systems inspired by the human brain."),
        Flashcard(title: "Deep Learning", description: "A type of ML using layered neural networks."),
        Flashcard(title: "Natural Language Processing", description: "AI that understands and generates human language.")
    ]

    let aiProblems: [AIProblem] = [
        AIProblem(title: "Water Jug Problem", description: "A classic puzzle involving measuring water using jugs of different sizes.", difficulty: "Medium"),
        AIProblem(title: "Tic-Tac-Toe", description: "A simple game that can be solved using AI algorithms.", difficulty: "Easy"),
        AIProblem(title: "Traveling Salesman Problem", description: "An optimization problem to find the shortest route visiting multiple cities.", difficulty: "Hard"),
        AIProblem(title: "Missionaries and Cannibals", description: "A river-crossing puzzle with constraints.", difficulty: "Medium"),
        AIProblem(title: "8-Puzzle Problem", description: "A sliding tile puzzle to rearrange tiles into a goal state.", difficulty: "Medium")
    ]

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#47258E"), .black]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack {
                //App Name
                HStack {
                    Spacer()
                    Text("LearnAI")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.trailing)
                }
                ScrollView {
                    VStack(spacing: 20) {
                        GeometryReader { geometry in
                            let cardWidth = geometry.size.width * 0.8
                            let spacing: CGFloat = 10
                            let totalWidth = (cardWidth + spacing) * CGFloat(narrativeSteps.count + 2)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: spacing) {
                                    CardView(step: narrativeSteps.last!)
                                        .frame(width: cardWidth, height: 220)
                                    ForEach(narrativeSteps, id: \.title) { step in
                                        CardView(step: step)
                                            .frame(width: cardWidth, height: 220)
                                    }
                                    CardView(step: narrativeSteps.first!)
                                        .frame(width: cardWidth, height: 220)
                                }
                                .frame(width: totalWidth)
                                .offset(x: -CGFloat(currentIndex) * (cardWidth + spacing) + offset)
                                .gesture(
                                    DragGesture()
                                        .onEnded { value in
                                            let threshold: CGFloat = 50
                                            if value.translation.width < -threshold {
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    currentIndex += 1
                                                }
                                            } else if value.translation.width > threshold {
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    currentIndex -= 1
                                                }
                                            }
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                                if currentIndex == narrativeSteps.count + 1 {
                                                    currentIndex = 1
                                                } else if currentIndex == 0 {
                                                    currentIndex = narrativeSteps.count
                                                }
                                            }
                                        }
                                )
                            }
                        }
                        .frame(height: 250)

                        EnhancedProblemArenaView(aiProblems: aiProblems, selectedProblem: $selectedAIProblem)
                    }
                    .padding(.bottom, 80)
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            showFlashcards.toggle()
                        }
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.bottom, 20)
            }
            
            if showFlashcards {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .blur(radius: 10)
                    .transition(.opacity)
                
                FlashcardView(flashcards: flashcards, showFlashcards: $showFlashcards)
                    .transition(.move(edge: .bottom))
            }
            if let problem = selectedAIProblem {
                           ProblemDetailView(problem: problem, isPresented: Binding(
                               get: { selectedAIProblem != nil },
                               set: { if !$0 { selectedAIProblem = nil } }
                           ))
                       }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct FlashcardView: View {
    let flashcards: [Flashcard]
    @Binding var showFlashcards: Bool
    @State private var currentIndex: Int = 0
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                ForEach(flashcards.indices, id: \.self) { index in
                    if index == currentIndex {
                        FlashcardCard(flashcard: flashcards[index])
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .opacity
                            ))
                            .gesture(
                                DragGesture()
                                    .onEnded { value in
                                        if value.translation.width < -50 {
                                            withAnimation {
                                                currentIndex = (currentIndex + 1) % flashcards.count
                                            }
                                        } else if value.translation.width > 50 {
                                            withAnimation {
                                                if currentIndex == 0 {
                                                    showFlashcards = false
                                                } else {
                                                    currentIndex = max(currentIndex - 1, 0)
                                                }
                                            }
                                        }
                                    }
                            )
                    }
                }
            }
            Spacer()
        }
    }
}

struct FlashcardCard: View {
    let flashcard: Flashcard
    
    var body: some View {
        VStack(spacing: 10) {
            Text(flashcard.title)
                .font(.headline)
                .foregroundColor(.white)
            Text(flashcard.description)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(width: 250, height: 150)
        .background(Color(hex: "#47258E"))
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}
struct AIProblem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let difficulty: String
}
struct EnhancedProblemArenaView: View {
    let aiProblems: [AIProblem]
    @Binding var selectedProblem: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("AI Problem Arena")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            ForEach(aiProblems) { problem in
                Button(action: {
                    withAnimation(.spring()) {
                        selectedProblem = problem.title
                    }
                }) {
                    HStack {
                        Text(problem.title)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(LinearGradient(gradient: Gradient(colors: [Color(hex: "#47258E"), Color(hex: "#47258E").opacity(0.7)]), startPoint: .leading, endPoint: .trailing))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .rotation3DEffect(.degrees(5), axis: (x: 1, y: 0, z: 0))
                    .scaleEffect(selectedProblem == problem.title ? 1.05 : 1.0)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(20)
        .shadow(color: Color.white.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}
struct ProblemDetailView: View {
    let problem: String
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)

            VStack {
                Text(problem)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()

                Button("Close") {
                    isPresented = false
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
    }
}

struct CardView: View {
    let step: NarrativeStep
    @State private var offset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: step.icon)
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.white)
            Text(step.title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(step.description)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(width: 300)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#47258E"), Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(15)
        .shadow(radius: 10)
        .offset(x: offset)
        .onAppear {
            withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
                offset = -300
            }
        }
    }
}

struct Flashcard {
    let title: String
    let description: String
}

struct NarrativeStep {
    let title: String
    let description: String
    let icon: String
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

