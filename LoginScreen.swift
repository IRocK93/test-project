import SwiftUI

struct LoginScreen: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Credentials") {
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                }
            }
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Login") {
                        auth.login(username: username, password: password)
                    }
                    .disabled(username.isEmpty || password.isEmpty)
                }
            }
        }
    }
}
