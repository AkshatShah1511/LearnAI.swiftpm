import SwiftUI

struct TravelingSalesmanView: View {
    @State private var showAIExplanation = false
    @State private var solutionSteps: [String] = []
    @State private var aiThinking = false
    @Environment(\.presentationMode) var presentationMode

    let mainColor = Color(red: 0.26, green: 0.13, blue: 0.53)
    let accentColor = Color.black

    // Sample City Data (Replace with your actual city coordinates)
    let cities = [
        City(name: "A", x: 50, y: 100),
        City(name: "B", x: 250, y: 150),
        City(name: "C", x: 150, y: 250),
        City(name: "D", x: 300, y: 350),
        City(name: "E", x: 100, y: 300)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [mainColor, .black]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

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
                            Text("Traveling Salesman Problem")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            Text("Goal: Find the shortest possible route that visits each city exactly once and returns to the origin city.")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(accentColor.opacity(0.7))
                                .cornerRadius(15)
                                .shadow(radius: 5)

                            // Visual Representation of Cities and Route
                            GeometryReader { geometry in
                                ZStack {
                                    ForEach(cities) { city in
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 20, height: 20)
                                            .position(x: CGFloat(city.x), y: CGFloat(city.y))
                                    }

                                    // Draw route if solution exists
                                    if !solutionSteps.isEmpty {
                                        Path { path in
                                            // Get city indices from the solution steps
                                            let cityIndices = solutionSteps.compactMap { step in
                                                cities.firstIndex { city in
                                                    step.contains(city.name)
                                                }
                                            }

                                            // Ensure we have valid indices
                                            guard cityIndices.count == cities.count else { return }

                                            // Move to the first city
                                            let firstCityIndex = cityIndices[0]
                                            path.move(to: CGPoint(x: CGFloat(cities[firstCityIndex].x), y: CGFloat(cities[firstCityIndex].y)))

                                            // Add lines to the other cities
                                            for i in 1..<cityIndices.count {
                                                let cityIndex = cityIndices[i]
                                                path.addLine(to: CGPoint(x: CGFloat(cities[cityIndex].x), y: CGFloat(cities[cityIndex].y)))
                                            }

                                            // Close the path back to the starting city
                                            path.addLine(to: CGPoint(x: CGFloat(cities[firstCityIndex].x), y: CGFloat(cities[firstCityIndex].y)))
                                        }
                                        .stroke(.yellow, lineWidth: 2)
                                    }
                                }
                            }
                            .frame(height: 400) // Adjust the frame size

                            if aiThinking {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
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
                                TSP_AIExplanationSlideshow(accentColor: accentColor)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            }

                            Button("Solve") {
                                solve()
                            }
                            .buttonStyle(SolveButtonStyle(color: accentColor))

                            if !solutionSteps.isEmpty {
                                SolutionStepsView(steps: solutionSteps, accentColor: accentColor)
                            }
                        }
                        .padding()
                    }
                }
            }
        }.navigationBarBackButtonHidden()
    }

    func solve() {
        aiThinking = true

        DispatchQueue.global(qos: .userInitiated).async {
            let (solution, _) = TravelingSalesmanSolver.solve(cities: cities) // Get solution and route
            DispatchQueue.main.async {
                solutionSteps = solution
                aiThinking = false
            }
        }
    }
}

struct TSP_AIExplanationSlideshow: View {
    let accentColor: Color
    @State private var currentSlide = 0

    let slides: [AISlide] = [
        AISlide(title: "AI Algorithm: Nearest Neighbor (Greedy)",
              content: "The Nearest Neighbor algorithm is a greedy approach. It doesn't guarantee the optimal solution but is simple to understand and implement."),

        AISlide(title: "Starting Point",
              content: "The algorithm starts at a random city. This initial city will be the beginning of our route."),

        AISlide(title: "Finding the Nearest City",
              content: "The algorithm looks for the nearest city to the current city that has not yet been visited."),

        AISlide(title: "Building the Route",
              content: "The algorithm adds the nearest unvisited city to the route and marks the city as visited."),

        AISlide(title: "Route Completion",
              content: "Once all cities have been visited, the route returns to the starting city, completing the tour."),

        AISlide(title: "Limitations of Nearest Neighbor",
              content: "Nearest Neighbor is a greedy approach and may not produce the shortest possible tour. More complex algorithms like Genetic Algorithms or Simulated Annealing are often used for better results.")
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

struct SolutionStepsView: View {
    let steps: [String]
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Solution Steps")
                .font(.headline)
                .foregroundColor(.white)

            ForEach(steps.indices, id: \.self) { index in
                Text("\(index + 1). \(steps[index])")
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(accentColor.opacity(0.2))
        .cornerRadius(20)
    }
}

struct ActionButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct TransferButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SolveButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .shadow(color: color.opacity(0.5), radius: 10, x: 0, y: 5)
    }
}

struct City: Identifiable {
    let id = UUID()
    let name: String
    let x: Int
    let y: Int
}

struct TravelingSalesmanSolver {
    static func solve(cities: [City]) -> ([String], [City]) {
        guard !cities.isEmpty else { return ([], []) }

        var unvisitedCities = cities
        var currentCity = unvisitedCities.removeFirst() // Start with the first city
        var route: [City] = [currentCity]
        var solutionSteps: [String] = ["Start at City \(currentCity.name)"]

        while !unvisitedCities.isEmpty {
            // Find the nearest unvisited city
            if let nearestCity = unvisitedCities.min(by: { distance(from: currentCity, to: $0) < distance(from: currentCity, to: $1) }) {
                route.append(nearestCity)
                solutionSteps.append("Visit City \(nearestCity.name)")
                currentCity = nearestCity
                unvisitedCities.removeAll { $0.id == nearestCity.id }
            } else {
                break // No more unvisited cities
            }
        }

        // Return to the starting city
        route.append(cities.first!)
        solutionSteps.append("Return to City \(cities.first!.name)")

        return (solutionSteps, route)
    }

    // Helper function to calculate distance between two cities
    static func distance(from city1: City, to city2: City) -> Double {
        let xDist = Double(city2.x - city1.x)
        let yDist = Double(city2.y - city1.y)
        return sqrt(xDist * xDist + yDist * yDist)
    }
}
