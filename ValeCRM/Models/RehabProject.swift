import Foundation

enum ProjectStatus: String, Codable, CaseIterable {
    case planning
    case active
    case onHold = "on_hold"
    case completed
    case cancelled
}

struct RehabProject: Identifiable, Codable {
    var id: String = UUID().uuidString
    var propertyAddress: String = ""
    var propertyName: String = ""
    var status: String = ProjectStatus.planning.rawValue
    var purchaseDate: String?
    var sellDate: String?
    var measuredSqft: Double?
    var rehabType: String?
    
    // Purchase Costs
    var propertyPurchase: Double?
    var homeInspection: Double?
    var appraisal: Double?
    var survey: Double?
    var lenderFees: Double?
    var purchaseClosingCosts: Double?
    var purchaseOther: Double?
    
    // Rehab Costs
    var totalContractor: Double?
    var totalMaterials: Double?
    
    // Holding Costs
    var mortgageInterest: Double?
    var investorMortgageInterest: Double?
    var propertyTaxes: Double?
    var insurance: Double?
    var totalUtilities: Double?
    var lawnCare: Double?
    var holdingOther: Double?
    
    // Selling Costs
    var salesRevenue: Double?
    var brokerCommissionPercent: Double?
    var homeWarranty: Double?
    var buyerTermite: Double?
    var closingCostsBuyer: Double?
    var sellingClosingCosts: Double?
    
    // Other
    var bankServiceCharges: Double?
    var quickbooksPropertyName: String?
    
    // Calculated fields (from API)
    var totalPurchaseCosts: Double?
    var totalRehabCosts: Double?
    var totalHoldingCosts: Double?
    var totalSellingCosts: Double?
    var totalExpenses: Double?
    var netIncome: Double?
    var totalInvestment: Double?
    var roi: Double?
    
    var createdAt: String?
    var updatedAt: String?
    
    // Computed properties for UI
    var displayName: String {
        propertyName.isEmpty ? propertyAddress : propertyName
    }
    
    var totalBudget: Double {
        (totalPurchaseCosts ?? 0) + (totalRehabCosts ?? 0) + (totalHoldingCosts ?? 0)
    }
    
    var totalSpent: Double {
        if let totalExpenses = totalExpenses {
            return totalExpenses
        }
        return (totalPurchaseCosts ?? 0) + (totalRehabCosts ?? 0) + (totalHoldingCosts ?? 0) + (totalSellingCosts ?? 0)
    }
    
    var remainingBudget: Double {
        max(totalBudget - totalSpent, 0)
    }
    
    var budgetUtilization: Double {
        guard totalBudget > 0 else { return 0 }
        return (totalSpent / totalBudget) * 100
    }
    
    var roiValue: Double {
        roi ?? 0
    }
    
    var startDate: Date? {
        guard let purchaseDate = purchaseDate else { return nil }
        return RehabProject.iso8601.date(from: purchaseDate)
    }
    
    var completionDate: Date? {
        guard let sellDate = sellDate else { return nil }
        return RehabProject.iso8601.date(from: sellDate)
    }
    
    var statusDisplay: String {
        status.replacingOccurrences(of: "_", with: " ").capitalized
    }
    
    private static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    enum CodingKeys: String, CodingKey {
        case id, status
        case propertyAddress
        case propertyName
        case purchaseDate
        case sellDate
        case measuredSqft
        case rehabType
        case propertyPurchase
        case homeInspection
        case appraisal
        case survey
        case lenderFees
        case purchaseClosingCosts
        case purchaseOther
        case totalContractor
        case totalMaterials
        case mortgageInterest
        case investorMortgageInterest
        case propertyTaxes
        case insurance
        case totalUtilities
        case lawnCare
        case holdingOther
        case salesRevenue
        case brokerCommissionPercent
        case homeWarranty
        case buyerTermite
        case closingCostsBuyer
        case sellingClosingCosts
        case bankServiceCharges
        case quickbooksPropertyName
        case totalPurchaseCosts
        case totalRehabCosts
        case totalHoldingCosts
        case totalSellingCosts
        case totalExpenses
        case netIncome
        case totalInvestment
        case roi
        case createdAt
        case updatedAt
    }
}
