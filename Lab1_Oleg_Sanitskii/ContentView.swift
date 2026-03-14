import SwiftUI

struct ContentView: View {
    
    @State private var currentNumber = Int.random(in: 2...100)
    @State private var correctAnswers = 0
    @State private var wrongAnswers = 0
    @State private var attempts = 0
    @State private var resultIcon: String? = nil

    var body: some View {
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
    }

    func checkAnswer(userSaysPrime: Bool) {
        let correctPrimeStatus = isPrime(currentNumber)

        if userSaysPrime == correctPrimeStatus {
            correctAnswers += 1
            resultIcon = "checkmark.circle.fill"
        } else {
            wrongAnswers += 1
            resultIcon = "xmark.circle.fill"
        }

        attempts += 1
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
