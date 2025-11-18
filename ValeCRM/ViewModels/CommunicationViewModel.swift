import Foundation
import Combine

final class CommunicationViewModel: ObservableObject {
    @Published var communications: [Communication] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedType: CommunicationType?
    
    private let networkService: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    var filteredCommunications: [Communication] {
        communications.filter { comm in
            let matchesSearch = searchText.isEmpty ||
                comm.content.localizedCaseInsensitiveContains(searchText) ||
                (comm.subject?.localizedCaseInsensitiveContains(searchText) ?? false)
            
            let matchesType = selectedType == nil || comm.type == selectedType
            
            return matchesSearch && matchesType
        }
        .sorted { $0.createdAt > $1.createdAt }
    }
    
    var recentCommunications: [Communication] {
        Array(filteredCommunications.prefix(10))
    }
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func fetchCommunications() {
        isLoading = true
        errorMessage = nil
        
        networkService.fetchCommunications()
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] communications in
                self?.communications = communications
            })
            .store(in: &cancellables)
    }
    
    func createCommunication(_ communication: Communication) {
        isLoading = true
        errorMessage = nil
        
        networkService.createCommunication(communication)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] communication in
                self?.communications.insert(communication, at: 0)
            })
            .store(in: &cancellables)
    }
    
    func updateCommunication(_ communication: Communication) {
        isLoading = true
        errorMessage = nil
        
        networkService.updateCommunication(communication)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] updatedCommunication in
                if let index = self?.communications.firstIndex(where: { $0.id == updatedCommunication.id }) {
                    self?.communications[index] = updatedCommunication
                }
            })
            .store(in: &cancellables)
    }
    
    func deleteCommunication(_ communication: Communication) {
        isLoading = true
        errorMessage = nil
        
        networkService.deleteCommunication(id: communication.id)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] _ in
                self?.communications.removeAll { $0.id == communication.id }
            })
            .store(in: &cancellables)
    }
    
    func clearFilters() {
        selectedType = nil
        searchText = ""
    }
}
