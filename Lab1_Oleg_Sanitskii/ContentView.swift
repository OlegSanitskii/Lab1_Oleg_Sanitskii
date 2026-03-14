import SwiftUI

struct ContentView: View {
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

            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
