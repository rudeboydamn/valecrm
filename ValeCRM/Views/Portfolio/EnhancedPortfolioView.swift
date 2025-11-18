import SwiftUI

struct EnhancedPortfolioView: View {
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("", selection: $selectedTab) {
                    Text("Dashboard").tag(0)
                    Text("Properties").tag(1)
                    Text("Residents").tag(2)
                    Text("Payments").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content based on selected tab
                if portfolioViewModel.isLoading {
                    Spacer()
                    ProgressView("Loading portfolio data...")
                    Spacer()
                } else if let error = portfolioViewModel.errorMessage {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.red)
                        Text(error)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            portfolioViewModel.fetchPortfolioData()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    Spacer()
                } else {
                    TabView(selection: $selectedTab) {
                        DashboardTabView(viewModel: portfolioViewModel)
                            .tag(0)
                        
                        PropertiesTabView(viewModel: portfolioViewModel)
                            .tag(1)
                        
                        ResidentsTabView(viewModel: portfolioViewModel)
                            .tag(2)
                        
                        PaymentsTabView(viewModel: portfolioViewModel)
                            .tag(3)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Portfolio Manager")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { portfolioViewModel.fetchPortfolioData() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                if portfolioViewModel.properties.isEmpty {
                    portfolioViewModel.fetchPortfolioData()
                }
            }
        }
    }
}

// MARK: - Dashboard Tab
struct DashboardTabView: View {
    @ObservedObject var viewModel: PortfolioViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let metrics = viewModel.dashboardMetrics {
                    // Primary Metrics
                    VStack(spacing: 12) {
                        MetricRow(
                            title: "Total Rent Due",
                            value: "$\(metrics.totalRentDue, default: "%.2f")",
                            icon: "dollarsign.circle.fill",
                            color: .blue
                        )
                        
                        MetricRow(
                            title: "Total Collected",
                            value: "$\(metrics.totalRentCollected, default: "%.2f")",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        
                        MetricRow(
                            title: "Collection Rate",
                            value: "\(metrics.collectionRate, default: "%.1f")%",
                            icon: "chart.line.uptrend.xyaxis",
                            color: metrics.collectionRate >= 90 ? .green : .orange
                        )
                        
                        Divider()
                        
                        MetricRow(
                            title: "Occupancy Rate",
                            value: "\(metrics.occupancyRate, default: "%.1f")%",
                            icon: "house.fill",
                            color: metrics.occupancyRate >= 90 ? .green : .orange
                        )
                        
                        MetricRow(
                            title: "Occupied Units",
                            value: "\(metrics.occupiedUnits) / \(metrics.totalUnits)",
                            icon: "person.3.fill",
                            color: .purple
                        )
                        
                        Divider()
                        
                        MetricRow(
                            title: "Portfolio Value",
                            value: "$\(metrics.totalPortfolioValue, default: "%.0f")",
                            icon: "building.2.fill",
                            color: .indigo
                        )
                        
                        MetricRow(
                            title: "Monthly Income",
                            value: "$\(metrics.totalMonthlyIncome, default: "%.2f")",
                            icon: "arrow.up.circle.fill",
                            color: .green
                        )
                        
                        MetricRow(
                            title: "Monthly Expenses",
                            value: "$\(metrics.totalMonthlyExpenses, default: "%.2f")",
                            icon: "arrow.down.circle.fill",
                            color: .red
                        )
                        
                        MetricRow(
                            title: "Net Cash Flow",
                            value: "$\(metrics.netMonthlyCashFlow, default: "%.2f")",
                            icon: "chart.bar.fill",
                            color: metrics.netMonthlyCashFlow >= 0 ? .green : .red
                        )
                    }
                    .padding()
                } else {
                    Text("No dashboard data available")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
        }
    }
}

// MARK: - Properties Tab
struct PropertiesTabView: View {
    @ObservedObject var viewModel: PortfolioViewModel
    
    var body: some View {
        List {
            if viewModel.properties.isEmpty {
                Text("No properties found")
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.properties, id: \.id) { property in
                    PropertyRow(property: property)
                }
            }
        }
    }
}

struct PropertyRow: View {
    let property: Property
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(property.address)
                .font(.headline)
            
            HStack {
                Text("\(property.city), \(property.state) \(property.zip)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let units = property.totalUnits {
                    Text("\(units) units")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            HStack {
                if let value = property.currentValue {
                    Label("$\(value, specifier: "%.0f")", systemImage: "dollarsign.circle")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                if let rent = property.monthlyRent {
                    Label("$\(rent, specifier: "%.0f")/mo", systemImage: "arrow.up")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Residents Tab
struct ResidentsTabView: View {
    @ObservedObject var viewModel: PortfolioViewModel
    
    var body: some View {
        List {
            if viewModel.residents.isEmpty {
                Text("No residents found")
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.residents, id: \.id) { resident in
                    ResidentRow(resident: resident)
                }
            }
        }
    }
}

struct ResidentRow: View {
    let resident: Resident
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(resident.firstName) \(resident.lastName)")
                .font(.headline)
            
            if let email = resident.email {
                Label(email, systemImage: "envelope")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let phone = resident.phone {
                Label(phone, systemImage: "phone")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text(resident.status.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(resident.status == "active" ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                if let moveInDate = resident.moveInDate {
                    Text("Moved in: \(moveInDate.prefix(10))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Payments Tab
struct PaymentsTabView: View {
    @ObservedObject var viewModel: PortfolioViewModel
    
    var body: some View {
        List {
            if viewModel.currentMonthPayments.isEmpty {
                Text("No payments found for current month")
                    .foregroundColor(.secondary)
            } else {
                Section("Paid (\(viewModel.paidPayments.count))") {
                    ForEach(viewModel.paidPayments, id: \.id) { payment in
                        PaymentRow(payment: payment)
                    }
                }
                
                Section("Unpaid (\(viewModel.unpaidPayments.count))") {
                    ForEach(viewModel.unpaidPayments, id: \.id) { payment in
                        PaymentRow(payment: payment)
                    }
                }
            }
        }
    }
}

struct PaymentRow: View {
    let payment: Payment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Due: \(payment.dueDate.prefix(10))")
                    .font(.headline)
                
                Spacer()
                
                Text(payment.status.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(payment.status == "paid" ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                    .cornerRadius(8)
            }
            
            HStack {
                Text("Amount Due: $\(payment.amountDue, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let paid = payment.amountPaid {
                    Text("Paid: $\(paid, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }
            
            if let paymentDate = payment.paymentDate, let method = payment.paymentMethod {
                HStack {
                    Text("Paid on: \(paymentDate.prefix(10))")
                    Text("•")
                    Text("Method: \(method)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Helper Views
struct MetricRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .foregroundColor(color)
        }
    }
}
