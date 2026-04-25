import Foundation
import SwiftUI

struct UserModel: Identifiable {
    let id = UUID()
    let name: String
    let role: String
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentUser: UserModel?

    func login(username: String, password: String) {
        self.currentUser = UserModel(name: username, role: "User")
        self.isLoggedIn = true
    }

    func logout() {
        self.currentUser = nil
        self.isLoggedIn = false
    }
}
