import Foundation
import Combine
import LocalAuthentication

enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case biometricNotAvailable
    case biometricFailed
    case keychainError(String)
    case networkError(String)
    case tokenExpired
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .biometricNotAvailable:
            return "Biometric authentication is not available on this device"
        case .biometricFailed:
            return "Biometric authentication failed"
        case .keychainError(let message):
            return "Keychain error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .tokenExpired:
            return "Your session has expired. Please log in again."
        }
    }
}

struct User: Codable {
    let id: String
    let userId: String  // This is the username
    let email: String
    let name: String
    let role: String
    let isActive: Bool?
    let createdAt: Date?
    let lastLogin: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "userId"
        case email
        case name
        case role
        case isActive = "isActive"
        case createdAt = "createdAt"
        case lastLogin = "lastLogin"
    }
}

struct AuthResponse: Codable {
    let user: User
    let token: String  // JWT token
    
    enum CodingKeys: String, CodingKey {
        case user
        case token
    }
}

final class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let networkService: NetworkService
    private let keychainHelper = KeychainHelper.shared
    private var cancellables = Set<AnyCancellable>()
    
    private let jwtTokenKey = "com.keystonevale.valeCRM.jwtToken"
    private let userKey = "com.keystonevale.valeCRM.user"
    private let shouldBypassAuth = true
    
    init(networkService: NetworkService) {
        self.networkService = networkService
        checkAuthStatus()
        if shouldBypassAuth && !isAuthenticated {
            bypassAuthentication()
        }
    }
    
    // MARK: - Authentication Methods
    
    func signIn(userId: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        let body: [String: String] = [
            "userId": userId,
            "password": password
        ]
        
        guard let jsonData = try? JSONEncoder().encode(body) else {
            errorMessage = "Failed to encode login data"
            isLoading = false
            return
        }
        
        networkService.request(from: "/api/auth/signin", method: "POST", body: jsonData)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] (response: AuthResponse) in
                self?.handleAuthSuccess(response)
            })
            .store(in: &cancellables)
    }
    
    
    func signOut() {
        do {
            try keychainHelper.delete(for: jwtTokenKey)
            try keychainHelper.delete(for: userKey)
        } catch {
            print("Error clearing keychain: \(error)")
        }
        
        // Clear NetworkService JWT token
        networkService.setAuthToken(nil)
        
        isAuthenticated = false
        currentUser = nil
    }
    
    func authenticateWithBiometrics(completion: @escaping (Result<Void, AuthError>) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            completion(.failure(.biometricNotAvailable))
            return
        }
        
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Authenticate to access ValeCRM"
        ) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.checkAuthStatus()
                    completion(.success(()))
                } else {
                    completion(.failure(.biometricFailed))
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleAuthSuccess(_ response: AuthResponse) {
        do {
            // Store JWT token
            try keychainHelper.save(response.token, for: jwtTokenKey)
            
            // Store user data
            let encoder = JSONEncoder()
            let userData = try encoder.encode(response.user)
            try keychainHelper.save(userData, for: userKey)
            
            // Update NetworkService with JWT token
            networkService.setAuthToken(response.token)
            
            currentUser = response.user
            isAuthenticated = true
        } catch {
            errorMessage = "Failed to save authentication data: \(error.localizedDescription)"
        }
    }
    
    private func checkAuthStatus() {
        do {
            let jwtToken = try keychainHelper.readString(for: jwtTokenKey)
            let userData = try keychainHelper.read(for: userKey)
            
            let decoder = JSONDecoder()
            let user = try decoder.decode(User.self, from: userData)
            
            if !jwtToken.isEmpty {
                // Update NetworkService with existing JWT token
                networkService.setAuthToken(jwtToken)
                currentUser = user
                isAuthenticated = true
            }
        } catch {
            isAuthenticated = false
            currentUser = nil
        }
    }

    private func bypassAuthentication() {
        let mockUser = User(
            id: UUID().uuidString,
            userId: "demo",
            email: "demo@keystonevale.org",
            name: "Demo User",
            role: "admin",
            isActive: true,
            createdAt: Date(),
            lastLogin: Date()
        )
        currentUser = mockUser
        isAuthenticated = true
        networkService.setAuthToken(nil)
    }
    
    func getJWTToken() -> String? {
        try? keychainHelper.readString(for: jwtTokenKey)
    }
}
