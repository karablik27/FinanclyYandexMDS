import SwiftUI
import Charts

public struct BalanceChartView: View {
    let entries: [BalanceEntry]
    @State private var selectedEntry: BalanceEntry?

    public init(entries: [BalanceEntry]) {
        self.entries = entries
    }

    public var body: some View {
        Chart {
            ForEach(entries) { entry in
                BarMark(
                    x: .value("Дата", entry.date),
                    y: .value("Баланс", entry.doubleBalance)
                )
                .foregroundStyle(entry.doubleBalance < 0 ? .red : .green)
                .cornerRadius(4)
                .annotation(position: .top, alignment: .center) {
                    if selectedEntry == entry {
                        Text(entry.doubleBalance.formatted(.number.precision(.fractionLength(0))))
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .chartYScale(domain: calculateYScale()) // фиксируем диапазон Y для лучшего визуала
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle().fill(Color.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let location = value.location
                                if let date: Date = proxy.value(atX: location.x) {
                                    let closest = entries.min(by: {
                                        abs($0.date.timeIntervalSince1970 - date.timeIntervalSince1970) <
                                        abs($1.date.timeIntervalSince1970 - date.timeIntervalSince1970)
                                    })
                                    selectedEntry = closest
                                }
                            }
                            .onEnded { _ in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    selectedEntry = nil
                                }
                            }
                    )
            }
        }
        .frame(height: 200)
        .padding(.horizontal)
        .padding(.top, 12)
    }

    private func calculateYScale() -> ClosedRange<Double> {
        let allValues = entries.map { $0.doubleBalance }
        guard let min = allValues.min(), let max = allValues.max() else {
            return -1000...1000
        }
        if min >= 0 {
            return 0...(max + 100)
        } else if max <= 0 {
            return (min - 100)...0
        } else {
            return (min - 100)...(max + 100)
        }
    }
}
