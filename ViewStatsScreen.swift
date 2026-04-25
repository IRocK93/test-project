import SwiftUI

struct ViewStatsScreen: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)

            Text("View Stats")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Statistics and analytics will be available soon.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}
