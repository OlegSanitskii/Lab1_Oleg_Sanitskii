import SwiftUI

struct ContentView: View {
    
    @State private var currentNumber = Int.random(in: 2...100)
    @State private var correctAnswers = 0
    @State private var wrongAnswers = 0
    @State private var attempts = 0
    @State private var resultIcon: String? = nil

    @State private var countdown = 5
    @State private var gameTimer: Timer? = nil

    @State private var showSummary = false

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Spacer()

                Text("Time: \(countdown)")
                    .font(.headline)
            }

            Spacer()

            Image(systemName: "number.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
                .foregroundColor(.blue)

            Text("Prime Number Game")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Choose whether the number is prime or not.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            Text("\(currentNumber)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .padding(.top, 20)

            Button(action: {
                checkAnswer(userSaysPrime: true)
            }) {
                Label("Prime", systemImage: "checkmark.seal")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue.opacity(0.15))
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            Button(action: {
                checkAnswer(userSaysPrime: false)
            }) {
                Label("Not Prime", systemImage: "xmark.seal")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.orange.opacity(0.15))
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            if let icon = resultIcon {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                    .foregroundColor(icon == "checkmark.circle.fill" ? .green : .red)
            }

            Spacer()

            VStack(spacing: 8) {
                Text("Correct: \(correctAnswers)")
                Text("Wrong: \(wrongAnswers)")
                Text("Attempt: \(attempts)/10")
            }
            .font(.headline)
        }
        .padding()
        .onAppear {
            startGameTimer()
        }
        .onDisappear {
            stopGameTimer()
        }
        .sheet(isPresented: $showSummary) {
            VStack(spacing: 20) {
                Text("Game Summary")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Correct: \(correctAnswers)")
                    .font(.title2)

                Text("Wrong: \(wrongAnswers)")
                    .font(.title2)

                Button("Start New Game") {
                    resetGame()
                    showSummary = false
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding()
        }
    }

    func startGameTimer() {
        stopGameTimer()
        countdown = 5

        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if countdown > 1 {
                countdown -= 1
            } else {
                stopGameTimer()
                timeExpired()
            }
        }
    }

    func stopGameTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }

    func timeExpired() {
        wrongAnswers += 1
        attempts += 1
        resultIcon = "xmark.circle.fill"
        goToNextRound()
    }

    func checkAnswer(userSaysPrime: Bool) {
        stopGameTimer()

        let correctPrimeStatus = isPrime(currentNumber)

        if userSaysPrime == correctPrimeStatus {
            correctAnswers += 1
            resultIcon = "checkmark.circle.fill"
        } else {
            wrongAnswers += 1
            resultIcon = "xmark.circle.fill"
        }

        attempts += 1
        goToNextRound()
    }

    func goToNextRound() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if attempts >= 10 {
                showSummary = true
            } else {
                currentNumber = Int.random(in: 2...100)
                resultIcon = nil
                startGameTimer()
            }
        }
    }

    func resetGame() {
        stopGameTimer()
        currentNumber = Int.random(in: 2...100)
        correctAnswers = 0
        wrongAnswers = 0
        attempts = 0
        resultIcon = nil
        countdown = 5
        startGameTimer()
    }

    func isPrime(_ number: Int) -> Bool {
        if number < 2 { return false }
        if number == 2 { return true }

        for i in 2..<number {
            if number % i == 0 {
                return false
            }
        }

        return true
    }
}

#Preview {
    ContentView()
}
