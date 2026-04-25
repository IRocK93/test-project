import SwiftUI

@main
struct TestProjectApp: App {
    @StateObject private var auth = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if auth.isLoggedIn {
                    HomeScreen()
                } else {
                    LoginScreen()
                }
            }
            .environmentObject(auth)
        }
    }
}
