import SwiftUI

struct BalanceChartLegend: View {
    let entry: BalanceEntry

    var body: some View {
        VStack(spacing: 4) {
            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.gray)

            Text(entry.balance.formatted(.currency(code: "RUB").precision(.fractionLength(0))))
                .font(.headline)
                .foregroundColor(entry.doubleBalance < 0 ? .red : .green)
        }
        .padding(6)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
