import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var userId = "dammy"
    @State private var password = "valley"
    @State private var didAttemptAutoLogin = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                // Logo/Branding
                Image(systemName: brandSymbolName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.blue)
                
                Text("ValeCRM")
                    .font(.system(size: 40, weight: .bold))
                
                Text("Manage your real estate business")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Login Form
                VStack(spacing: 15) {
                    TextField("User ID", text: $userId)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.username)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.password)
                    
                    if let error = authManager.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button(action: {
                        authManager.signIn(userId: userId, password: password)
                    }) {
                        if authManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Sign In")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(authManager.isLoading || userId.isEmpty || password.isEmpty)
                    
                    Button(action: {
                        authManager.authenticateWithBiometrics { result in
                            switch result {
                            case .success:
                                print("Biometric auth successful")
                            case .failure(let error):
                                authManager.errorMessage = error.localizedDescription
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "faceid")
                            Text("Sign In with Face ID")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 50)
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Sign Up Link
                VStack(spacing: 4) {
                    Text("Need access?")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Text("Please contact the Keystone Vale admin team to request an account.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
            .navigationBarHidden(true)
            .onAppear(perform: attemptAutoLogin)
        }
    }
    
    private var brandSymbolName: String {
        return "house.circle.fill"
    }
    
    private func attemptAutoLogin() {
        guard !didAttemptAutoLogin else { return }
        didAttemptAutoLogin = true
        authManager.signIn(userId: userId, password: password)
    }
}
