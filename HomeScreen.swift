import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var auth: AuthViewModel

    enum Destination: Hashable {
        case sendMessage
        case uploadPhoto
        case viewStats
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let user = auth.currentUser {
                        UserBadgeView(user: user)
                    }

                    VStack(spacing: 16) {
                        Text("Quick Actions")
                            .font(.headline)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            NavigationLink(destination: SendMessageScreen()) {
                                actionButton(icon: "paperplane.fill", title: "Send Message")
                            }

                            NavigationLink(destination: UploadPhotoScreen()) {
                                actionButton(icon: "photo.fill", title: "Upload Photo")
                            }

                            NavigationLink(destination: ViewStatsScreen()) {
                                actionButton(icon: "chart.bar.fill", title: "View Stats")
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        auth.logout()
                    }
                }
            }
        }
    }

    private func actionButton(icon: String, title: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
