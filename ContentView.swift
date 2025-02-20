import SwiftUI
import CoreHaptics

struct ContentView: View {
    @State private var isAnimating: Bool = false
    @State private var dragOffset: CGFloat = 0
    @State private var navigateToNextScreen: Bool = false
    @State private var engine: CHHapticEngine?
    
    private let maxSwipeWidth: CGFloat = 300
    private let swipeThreshold: CGFloat = 200
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    Text("LearnAI")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 5)
                    
                    Spacer()
                    
                    Text("Slide to Start Learning AI")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .onAppear {
                            isAnimating = true
                            prepareHaptics()
                        }
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 25)
                            .frame(width: maxSwipeWidth, height: 70)
                            .foregroundColor(Color.primary.opacity(0.1)) // Adaptive background
                        
                        RoundedRectangle(cornerRadius: 25)
                            .frame(width: dragOffset + 70, height: 70)
                            .foregroundColor(Color.primary.opacity(0.3))
                        
                        RoundedRectangle(cornerRadius: 25)
                            .frame(width: 70, height: 70)
                            .foregroundColor(.primary) // Use primary color for the background
                            .overlay(
                                Image(systemName: "brain")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(.systemBackground)) // Use system background color for the brain icon
                                    .shadow(color: .white.opacity(0.3), radius: 5) // Optional glow effect
                            )
                            .offset(x: dragOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        if gesture.translation.width > 0 && gesture.translation.width <= (maxSwipeWidth - 50) {
                                            dragOffset = gesture.translation.width
                                        }
                                    }
                                    .onEnded { gesture in
                                        if dragOffset > swipeThreshold {
                                            navigateToNextScreen = true
                                            dragOffset = 0
                                            triggerHaptic()
                                        } else {
                                            withAnimation(.spring()) {
                                                dragOffset = 0
                                            }
                                        }
                                    }
                            )
                    }
                    .padding(.top, 30)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationDestination(isPresented: $navigateToNextScreen) {
                NextScreen()
            }
        }
    }
    
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Error starting haptic engine: \(error)")
        }
    }
    
    private func triggerHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Error playing haptic: \(error)")
        }
    }
}
