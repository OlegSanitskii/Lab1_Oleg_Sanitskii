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

            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
