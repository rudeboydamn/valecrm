import Foundation
import Combine

final class ClientViewModel: ObservableObject {
    @Published var clients: [Client] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedType: ClientType?
    @Published var selectedStatus: ClientStatus?
    
    private let networkService: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    var filteredClients: [Client] {
        clients.filter { client in
            let matchesSearch = searchText.isEmpty ||
                client.fullName.localizedCaseInsensitiveContains(searchText) ||
                client.email.localizedCaseInsensitiveContains(searchText) ||
                (client.company?.localizedCaseInsensitiveContains(searchText) ?? false)
            
            let matchesType = selectedType == nil || client.type == selectedType
            let matchesStatus = selectedStatus == nil || client.status == selectedStatus
            
            return matchesSearch && matchesType && matchesStatus
        }
    }
    
    var activeClients: [Client] {
        clients.filter { $0.status == .active }
    }
    
    var recentClients: [Client] {
        Array(clients.prefix(5))
    }
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func fetchClients() {
        isLoading = true
        errorMessage = nil
        
        networkService.fetchClients()
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] clients in
                self?.clients = clients
            })
            .store(in: &cancellables)
    }
    
    func createClient(_ client: Client) {
        isLoading = true
        errorMessage = nil
        
        networkService.createClient(client)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] client in
                self?.clients.insert(client, at: 0)
            })
            .store(in: &cancellables)
    }
    
    func updateClient(_ client: Client) {
        isLoading = true
        errorMessage = nil
        
        networkService.updateClient(client)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] updatedClient in
                if let index = self?.clients.firstIndex(where: { $0.id == updatedClient.id }) {
                    self?.clients[index] = updatedClient
                }
            })
            .store(in: &cancellables)
    }
    
    func deleteClient(_ client: Client) {
        isLoading = true
        errorMessage = nil
        
        networkService.deleteClient(id: client.id)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] _ in
                self?.clients.removeAll { $0.id == client.id }
            })
            .store(in: &cancellables)
    }
    
    func clearFilters() {
        selectedType = nil
        selectedStatus = nil
        searchText = ""
    }
}
