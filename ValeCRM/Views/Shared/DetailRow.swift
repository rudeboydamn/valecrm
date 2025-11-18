import SwiftUI

struct DetailRow: View {
    let label: String
    let value: String
    var icon: String?
    var valueColor: Color = .primary
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            if let icon {
                Label(label, systemImage: icon)
                    .foregroundColor(.secondary)
            } else {
                Text(label)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(valueColor)
        }
    }
}
