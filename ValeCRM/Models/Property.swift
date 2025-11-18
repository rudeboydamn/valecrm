import Foundation

enum PropertyType: String, Codable, CaseIterable {
    case singleFamily = "single_family"
    case multiFamily = "multi_family"
    case condo
    case townhouse
    case land
    case commercial
}

enum PropertyStatus: String, Codable, CaseIterable {
    case owned
    case forSale = "for_sale"
    case underContract = "under_contract"
    case rehabbing
    case rental
}

struct Property: Identifiable, Codable {
    let id: String  // Changed from UUID to String for API compatibility
    var address: String
    var city: String
    var state: String
    var zip: String
    var propertyType: String  // Changed to String for flexibility
    var status: String?  // Changed to optional String
    var purchasePrice: Double?
    var currentValue: Double?
    var monthlyRent: Double?
    var monthlyExpenses: Double?
    var totalUnits: Int?
    var propertyTaxAnnual: Double?
    var insuranceAnnual: Double?
    var hoaMonthly: Double?
    var purchaseDate: String?

    var monthlyCashFlow: Double { (monthlyRent ?? 0) - (monthlyExpenses ?? 0) }
    var annualCashFlow: Double { monthlyCashFlow * 12 }
    var roi: Double {
        guard let purchase = purchasePrice, purchase > 0 else { return 0 }
        return (annualCashFlow / purchase) * 100
    }
    
    enum CodingKeys: String, CodingKey {
        case id, address, city, state, status
        case zip = "zipCode"
        case propertyType
        case purchasePrice
        case currentValue = "marketValue"
        case monthlyRent
        case monthlyExpenses
        case totalUnits
        case propertyTaxAnnual
        case insuranceAnnual
        case hoaMonthly
        case purchaseDate
    }
}
