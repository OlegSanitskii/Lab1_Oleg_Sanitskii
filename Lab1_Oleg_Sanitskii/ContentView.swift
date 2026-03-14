import SwiftUI

struct ContentView: View {
    
    @State private var currentNumber = Int.random(in: 2...100)

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

            Spacer()
        }
        .padding()
    }

    func checkAnswer(userSaysPrime: Bool) {
        let correctPrimeStatus = isPrime(currentNumber)
        let _ = (userSaysPrime == correctPrimeStatus)
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
