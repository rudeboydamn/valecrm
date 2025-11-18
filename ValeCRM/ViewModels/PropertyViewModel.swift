import Foundation
import Combine

final class PropertyViewModel: ObservableObject {
    @Published var properties: [Property] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedType: String?
    @Published var selectedStatus: String?
    
    private let networkService: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    var filteredProperties: [Property] {
        properties.filter { property in
            let matchesSearch = searchText.isEmpty ||
                property.address.localizedCaseInsensitiveContains(searchText) ||
                property.city.localizedCaseInsensitiveContains(searchText)
            
            let matchesType = selectedType == nil || property.propertyType == selectedType
            let matchesStatus = selectedStatus == nil || property.status == selectedStatus
            
            return matchesSearch && matchesType && matchesStatus
        }
    }
    
    var totalPortfolioValue: Double {
        properties.compactMap { $0.currentValue }.reduce(0, +)
    }
    
    var totalMonthlyIncome: Double {
        properties.compactMap { $0.monthlyRent }.reduce(0, +)
    }
    
    var totalMonthlyExpenses: Double {
        properties.compactMap { $0.monthlyExpenses }.reduce(0, +)
    }
    
    var netMonthlyCashFlow: Double {
        totalMonthlyIncome - totalMonthlyExpenses
    }
    
    var averageROI: Double {
        let rois = properties.map { $0.roi }.filter { $0 > 0 }
        guard !rois.isEmpty else { return 0 }
        return rois.reduce(0, +) / Double(rois.count)
    }
    
    var rentalProperties: [Property] {
        properties.filter { $0.status == "rental" }
    }
    
    var activeProperties: [Property] {
        properties.filter { $0.status != "for_sale" }
    }
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func fetchProperties() {
        isLoading = true
        errorMessage = nil
        
        networkService.fetchProperties()
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] properties in
                self?.properties = properties
            })
            .store(in: &cancellables)
    }
    
    func createProperty(_ property: Property) {
        isLoading = true
        errorMessage = nil
        
        networkService.createProperty(property)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] newProperty in
                self?.properties.append(newProperty)
            })
            .store(in: &cancellables)
    }
    
    func updateProperty(_ property: Property) {
        isLoading = true
        errorMessage = nil
        
        networkService.updateProperty(property)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] updatedProperty in
                if let index = self?.properties.firstIndex(where: { $0.id == updatedProperty.id }) {
                    self?.properties[index] = updatedProperty
                }
            })
            .store(in: &cancellables)
    }
    
    func deleteProperty(_ property: Property) {
        isLoading = true
        errorMessage = nil
        
        networkService.deleteProperty(id: property.id)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] _ in
                self?.properties.removeAll { $0.id == property.id }
            })
            .store(in: &cancellables)
    }
    
    func clearFilters() {
        selectedType = nil
        selectedStatus = nil
        searchText = ""
    }
}
