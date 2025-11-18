import SwiftUI

@main
struct CRMApp: App {
    @StateObject private var authManager: AuthManager
    
    init() {
        let networkService = NetworkService.shared
        _authManager = StateObject(wrappedValue: AuthManager(networkService: networkService))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}
