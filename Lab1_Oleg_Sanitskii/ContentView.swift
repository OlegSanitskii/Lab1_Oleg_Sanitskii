import SwiftUI

struct AttemptResult: Identifiable, Hashable {
    let id = UUID()
    let number: Int
    let userAnswer: Bool?
    let correctAnswer: Bool
    let explanation: String
    let wasCorrect: Bool
}

struct GameRecord: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let correctAnswers: Int
    let wrongAnswers: Int
    let attempts: [AttemptResult]
}

enum AppScreen {
    case mainMenu
    case readyCountdown
    case playing
    case statistics
}

struct ContentView: View {
    
    @State private var currentScreen: AppScreen = .mainMenu

    @State private var currentNumber = Int.random(in: 2...100)
    @State private var correctAnswers = 0
    @State private var wrongAnswers = 0
    @State private var attempts = 0
    @State private var resultIcon: String? = nil

    @State private var countdown = 5
    @State private var readyCountdown = 5

    @State private var gameTimer: Timer? = nil
    @State private var readyTimer: Timer? = nil

    @State private var showSummary = false
    @State private var history: [AttemptResult] = []
    @State private var gameRecords: [GameRecord] = []
    @State private var selectedGameRecord: GameRecord? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                switch currentScreen {
                case .mainMenu:
                    mainMenuView

                case .readyCountdown:
                    readyView

                case .playing:
                    gameView

                case .statistics:
                    statisticsView
                }
            }
            .navigationDestination(item: $selectedGameRecord) { record in
                StoredGameSummaryView(record: record)
            }
            .sheet(isPresented: $showSummary) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Game Summary")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Correct: \(correctAnswers)")
                            .font(.title2)

                        Text("Wrong: \(wrongAnswers)")
                            .font(.title2)

                        Divider()

                        ForEach(Array(history.enumerated()), id: \.element.id) { index, item in
                            AttemptCardView(index: index, item: item)
                        }

                        Button("Start New Game") {
                            resetGame()
                            showSummary = false
                            currentScreen = .mainMenu
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .onDisappear {
                stopAllTimers()
            }
        }
    }

    var mainMenuView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "number.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
                .foregroundColor(.blue)

            Text("Prime Number Game")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Choose whether each number is prime or not before time runs out.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            VStack(spacing: 14) {
                Button(action: {
                    resetGame()
                    startReadyCountdown()
                }) {
                    Label("Start Game", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }

                Button(action: {
                    currentScreen = .statistics
                }) {
                    Label("View Statistics", systemImage: "chart.bar.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.green)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
            }
            .padding(.horizontal, 30)

            Spacer()
        }
        .padding()
    }

    var readyView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "hourglass")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.orange)

            Text("Get Ready")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("\(readyCountdown)")
                .font(.system(size: 90, weight: .heavy, design: .rounded))
                .foregroundColor(.blue)

            Text("The game will begin in a moment...")
                .font(.title3)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
    }

    var gameView: some View {
        VStack(spacing: 24) {
            HStack {
                Spacer()

                Text("Time: \(countdown)")
                    .font(.headline)
            }

            Spacer()

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
    }

    var statisticsView: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Statistics")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Games Played: \(gameRecords.count)")
                .font(.title2)

            Text("Total Correct: \(gameRecords.reduce(0) { $0 + $1.correctAnswers })")
                .font(.title3)
                .foregroundColor(.green)

            Text("Total Wrong: \(gameRecords.reduce(0) { $0 + $1.wrongAnswers })")
                .font(.title3)
                .foregroundColor(.red)

            if !gameRecords.isEmpty {
                Text("Game History")
                    .font(.headline)

                ForEach(gameRecords) { record in
                    Button(action: {
                        selectedGameRecord = record
                    }) {
                        Text(record.date.formatted(date: .abbreviated, time: .shortened))
                    }
                }
            }

            Spacer()

            Button(action: {
                currentScreen = .mainMenu
            }) {
                Label("Back to Main Menu", systemImage: "house.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }

    func startReadyCountdown() {
        stopAllTimers()
        readyCountdown = 5
        currentScreen = .readyCountdown

        readyTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if readyCountdown > 1 {
                readyCountdown -= 1
            } else {
                stopReadyTimer()
                currentScreen = .playing
            }
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

    func stopReadyTimer() {
        readyTimer?.invalidate()
        readyTimer = nil
    }

    func stopAllTimers() {
        stopGameTimer()
        stopReadyTimer()
    }

    func timeExpired() {
        let correctPrimeStatus = isPrime(currentNumber)
        let explanation = buildExplanation(for: currentNumber, isPrimeResult: correctPrimeStatus)

        wrongAnswers += 1
        attempts += 1
        resultIcon = "xmark.circle.fill"

        history.append(
            AttemptResult(
                number: currentNumber,
                userAnswer: nil,
                correctAnswer: correctPrimeStatus,
                explanation: explanation,
                wasCorrect: false
            )
        )

        goToNextRound()
    }

    func checkAnswer(userSaysPrime: Bool) {
        stopGameTimer()

        let correctPrimeStatus = isPrime(currentNumber)
        let wasCorrect = (userSaysPrime == correctPrimeStatus)
        let explanation = buildExplanation(for: currentNumber, isPrimeResult: correctPrimeStatus)

        if wasCorrect {
            correctAnswers += 1
            resultIcon = "checkmark.circle.fill"
        } else {
            wrongAnswers += 1
            resultIcon = "xmark.circle.fill"
        }

        attempts += 1

        history.append(
            AttemptResult(
                number: currentNumber,
                userAnswer: userSaysPrime,
                correctAnswer: correctPrimeStatus,
                explanation: explanation,
                wasCorrect: wasCorrect
            )
        )

        goToNextRound()
    }

    func goToNextRound() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if attempts >= 10 {
                let record = GameRecord(
                    date: Date(),
                    correctAnswers: correctAnswers,
                    wrongAnswers: wrongAnswers,
                    attempts: history
                )

                gameRecords.append(record)
                showSummary = true
            } else {
                currentNumber = Int.random(in: 2...100)
                resultIcon = nil
                startGameTimer()
            }
        }
    }

    func resetGame() {
        stopAllTimers()
        currentNumber = Int.random(in: 2...100)
        correctAnswers = 0
        wrongAnswers = 0
        attempts = 0
        resultIcon = nil
        countdown = 5
        readyCountdown = 5
        history.removeAll()
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

    func divisors(of number: Int) -> [Int] {
        guard number > 0 else { return [] }

        var result: [Int] = []

        for i in 1...number {
            if number % i == 0 {
                result.append(i)
            }
        }

        return result
    }

    func factorPairs(of number: Int) -> [String] {
        guard number > 0 else { return [] }

        var pairs: [String] = []

        for i in 1...number {
            if number % i == 0 {
                let pair = number / i
                if i <= pair {
                    pairs.append("\(i) × \(pair)")
                }
            }
        }

        return pairs
    }

    func buildExplanation(for number: Int, isPrimeResult: Bool) -> String {
        let divisorsList = divisors(of: number).map { String($0) }.joined(separator: ", ")
        let factorPairsList = factorPairs(of: number).joined(separator: "; ")

        if isPrimeResult {
            return "\(number) is prime because it has exactly 2 divisors: 1 and \(number). Factor pairs: \(factorPairsList)."
        } else {
            return "\(number) is not prime because it has more than 2 divisors. Divisors: \(divisorsList). Factor pairs: \(factorPairsList)."
        }
    }
}

struct AttemptCardView: View {
    let index: Int
    let item: AttemptResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Attempt \(index + 1)")
                    .font(.headline)

                Spacer()

                Image(systemName: item.wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(item.wasCorrect ? .green : .red)
            }

            Text("Number: \(item.number)")
            Text("Your answer: \(userAnswerText(item.userAnswer))")
            Text("Correct answer: \(item.correctAnswer ? "Prime" : "Not Prime")")
            Text("Explanation: \(item.explanation)")
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    func userAnswerText(_ answer: Bool?) -> String {
        if let answer = answer {
            return answer ? "Prime" : "Not Prime"
        } else {
            return "No answer (time expired)"
        }
    }
}

struct StoredGameSummaryView: View {
    let record: GameRecord

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Saved Game")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(record.date.formatted(date: .complete, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Correct: \(record.correctAnswers)")
                    .font(.title2)

                Text("Wrong: \(record.wrongAnswers)")
                    .font(.title2)

                Divider()

                ForEach(Array(record.attempts.enumerated()), id: \.element.id) { index, item in
                    AttemptCardView(index: index, item: item)
                }
            }
            .padding()
        }
        .navigationTitle("Saved Summary")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
}
