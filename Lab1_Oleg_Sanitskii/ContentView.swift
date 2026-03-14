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
    @State private var showResultIcon = false

    @State private var countdown = 5
    @State private var readyCountdown = 5

    @State private var gameTimer: Timer? = nil
    @State private var readyTimer: Timer? = nil

    @State private var currentGameHistory: [AttemptResult] = []
    @State private var gameRecords: [GameRecord] = []

    @State private var showCurrentGameSummary = false
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
            .sheet(isPresented: $showCurrentGameSummary) {
                CurrentGameSummaryView(
                    correctAnswers: correctAnswers,
                    wrongAnswers: wrongAnswers,
                    history: currentGameHistory,
                    onPlayAgain: {
                        showCurrentGameSummary = false
                        resetCurrentGameData()
                        startReadyCountdown()
                    },
                    onBackToMainMenu: {
                        showCurrentGameSummary = false
                        resetAllForMenu()
                    }
                )
            }
            .onDisappear {
                stopAllTimers()
            }
        }
    }

    // MARK: - Main Menu

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
                    resetCurrentGameData()
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

            VStack(spacing: 8) {
                Label("10 attempts per game", systemImage: "list.number")
                Label("5 seconds for each number", systemImage: "timer")
                Label("Detailed game summaries", systemImage: "doc.text.magnifyingglass")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
    }

    // MARK: - Ready View

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

    // MARK: - Game View

    var gameView: some View {
        VStack {
            HStack {
                Spacer()

                Label("Time: \(countdown)", systemImage: "timer")
                    .font(.headline)
                    .padding(.top, 10)
                    .padding(.trailing, 10)
            }

            ProgressView(value: Double(countdown), total: 5.0)
                .padding(.horizontal)
                .padding(.top, 4)

            Spacer()

            Text("\(currentNumber)")
                .font(.system(size: 76, weight: .bold, design: .rounded))
                .padding(.bottom, 30)

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
            .padding(.top, 12)

            if let icon = resultIcon, showResultIcon {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                    .foregroundColor(icon == "checkmark.circle.fill" ? .green : .red)
                    .scaleEffect(showResultIcon ? 1.0 : 0.5)
                    .opacity(showResultIcon ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.25), value: showResultIcon)
                    .padding(.top, 30)
            }

            Spacer()

            VStack(spacing: 8) {
                Label("Correct: \(correctAnswers)", systemImage: "checkmark.circle")
                Label("Wrong: \(wrongAnswers)", systemImage: "xmark.circle")
                Label("Attempt: \(attempts)/10", systemImage: "number.circle")
            }
            .font(.headline)
            .padding(.bottom, 20)
        }
        .padding()
    }

    // MARK: - Statistics View

    var statisticsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Statistics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 8)

                if gameRecords.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "chart.bar.xaxis")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)

                        Text("No games played yet")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text("Play at least one game to see statistics here.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Overall Stats")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        VStack(spacing: 0) {
                            StatisticsLine(
                                title: "Games Played: \(gameRecords.count)",
                                systemImage: "gamecontroller.fill",
                                tint: .blue
                            )

                            Divider().padding(.leading, 44)

                            StatisticsLine(
                                title: "Total Correct: \(gameRecords.reduce(0) { $0 + $1.correctAnswers })",
                                systemImage: "checkmark.circle.fill",
                                tint: .green
                            )

                            Divider().padding(.leading, 44)

                            StatisticsLine(
                                title: "Total Wrong: \(gameRecords.reduce(0) { $0 + $1.wrongAnswers })",
                                systemImage: "xmark.circle.fill",
                                tint: .red
                            )
                        }
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(18)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Game History")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        ForEach(Array(gameRecords.enumerated().reversed()), id: \.element.id) { index, record in
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Game \(gameRecords.count - index)")
                                    .font(.headline)

                                Text(record.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                HStack(spacing: 16) {
                                    Label("\(record.correctAnswers)", systemImage: "checkmark.circle.fill")
                                        .foregroundColor(.green)

                                    Label("\(record.wrongAnswers)", systemImage: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                                .font(.subheadline)

                                Divider()

                                Button(action: {
                                    selectedGameRecord = record
                                }) {
                                    Label("View Details", systemImage: "doc.text.magnifyingglass")
                                        .font(.subheadline.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(Color.blue.opacity(0.12))
                                        .foregroundColor(.blue)
                                        .cornerRadius(10)
                                }
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(18)
                        }
                    }
                }

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
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Game Flow

    func startReadyCountdown() {
        stopAllTimers()

        readyCountdown = 5
        currentScreen = .readyCountdown

        readyTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if readyCountdown > 1 {
                readyCountdown -= 1
            } else {
                stopReadyTimer()
                beginGame()
            }
        }
    }

    func beginGame() {
        currentScreen = .playing
        currentNumber = Int.random(in: 2...100)
        resultIcon = nil
        showResultIcon = false
        startGameTimer()
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

    func showAnimatedResultIcon(_ iconName: String) {
        resultIcon = iconName
        showResultIcon = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            showResultIcon = true
        }
    }

    func checkAnswer(userSaysPrime: Bool) {
        guard currentScreen == .playing else { return }

        stopGameTimer()

        let correctPrimeStatus = isPrime(currentNumber)
        let wasCorrect = (userSaysPrime == correctPrimeStatus)

        if wasCorrect {
            correctAnswers += 1
            showAnimatedResultIcon("checkmark.circle.fill")
        } else {
            wrongAnswers += 1
            showAnimatedResultIcon("xmark.circle.fill")
        }

        let explanation = buildExplanation(for: currentNumber, isPrimeResult: correctPrimeStatus)

        currentGameHistory.append(
            AttemptResult(
                number: currentNumber,
                userAnswer: userSaysPrime,
                correctAnswer: correctPrimeStatus,
                explanation: explanation,
                wasCorrect: wasCorrect
            )
        )

        goToNextAttempt()
    }

    func timeExpired() {
        wrongAnswers += 1
        showAnimatedResultIcon("xmark.circle.fill")

        let correctPrimeStatus = isPrime(currentNumber)
        let explanation = buildExplanation(for: currentNumber, isPrimeResult: correctPrimeStatus)

        currentGameHistory.append(
            AttemptResult(
                number: currentNumber,
                userAnswer: nil,
                correctAnswer: correctPrimeStatus,
                explanation: explanation,
                wasCorrect: false
            )
        )

        goToNextAttempt()
    }

    func goToNextAttempt() {
        attempts += 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if attempts >= 10 {
                finishCurrentGame()
            } else {
                currentNumber = Int.random(in: 2...100)
                resultIcon = nil
                showResultIcon = false
                startGameTimer()
            }
        }
    }

    func finishCurrentGame() {
        stopGameTimer()

        let record = GameRecord(
            date: Date(),
            correctAnswers: correctAnswers,
            wrongAnswers: wrongAnswers,
            attempts: currentGameHistory
        )

        gameRecords.append(record)
        showCurrentGameSummary = true
    }

    func resetCurrentGameData() {
        stopAllTimers()

        currentNumber = Int.random(in: 2...100)
        correctAnswers = 0
        wrongAnswers = 0
        attempts = 0
        resultIcon = nil
        showResultIcon = false
        countdown = 5
        readyCountdown = 5
        currentGameHistory.removeAll()
    }

    func resetAllForMenu() {
        resetCurrentGameData()
        currentScreen = .mainMenu
    }

    // MARK: - Math Helpers

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

// MARK: - Current Game Summary

struct CurrentGameSummaryView: View {
    let correctAnswers: Int
    let wrongAnswers: Int
    let history: [AttemptResult]
    let onPlayAgain: () -> Void
    let onBackToMainMenu: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Game Summary")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    HStack(spacing: 16) {
                        Label("Correct: \(correctAnswers)", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)

                        Label("Wrong: \(wrongAnswers)", systemImage: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                    .font(.title3)

                    Divider()

                    ForEach(Array(history.enumerated()), id: \.element.id) { index, item in
                        AttemptCardView(index: index, item: item)
                    }

                    VStack(spacing: 12) {
                        Button(action: {
                            onPlayAgain()
                        }) {
                            Label("Play Again", systemImage: "arrow.clockwise")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        Button(action: {
                            onBackToMainMenu()
                        }) {
                            Label("Back to Main Menu", systemImage: "house.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Stored Game Summary

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

                HStack(spacing: 16) {
                    Label("Correct: \(record.correctAnswers)", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)

                    Label("Wrong: \(record.wrongAnswers)", systemImage: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
                .font(.title3)

                Divider()

                Text("Answer History")
                    .font(.title2)
                    .fontWeight(.semibold)

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

// MARK: - Shared Detailed Attempt Card

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

            Label("Number: \(item.number)", systemImage: "number.circle")
            Label("Your answer: \(userAnswerText(item.userAnswer))", systemImage: "person.crop.circle")
            Label("Correct answer: \(item.correctAnswer ? "Prime" : "Not Prime")", systemImage: "checklist")
            Label("Result: \(item.wasCorrect ? "Correct" : "Wrong")", systemImage: item.wasCorrect ? "hand.thumbsup.fill" : "hand.thumbsdown.fill")
                .foregroundColor(item.wasCorrect ? .green : .red)

            Text("Explanation: \(item.explanation)")
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 4)
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

// MARK: - Statistics Line

struct StatisticsLine: View {
    let title: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundColor(tint)
                .frame(width: 24)

            Text(title)
                .foregroundColor(tint == .blue ? .primary : tint)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
