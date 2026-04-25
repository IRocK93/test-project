import SwiftUI

struct SendMessageScreen: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)

            Text("Send Message")
                .font(.title2)
                .fontWeight(.semibold)

            Text("This feature is coming soon. Stay tuned for updates!")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}
