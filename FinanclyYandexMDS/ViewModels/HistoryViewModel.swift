import Foundation

// MARK: - HistoryViewModel

@MainActor
final class HistoryViewModel: ObservableObject {
    
    // MARK: - Published Properties

    @Published var transactions: [Transaction] = []
    @Published var total: Decimal = 0
    @Published var startDate: Date
    @Published var endDate: Date

    // MARK: - Private Properties

    private let direction: Direction
    private let service = TransactionsService()

    // MARK: - Init
    init(direction: Direction) {
        self.direction = direction

        let calendar = Calendar.current
        let now = Date()
        self.endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now)!
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
        self.startDate = calendar.startOfDay(for: oneMonthAgo)

        Task { await load() }
    }

    // MARK: - Data Loading
    func load() async {
        let all = await service.getTransactions(
            from: startDate.startOfDay(),
            to: endDate.endOfDay()
        )
        let filtered = all.filter { $0.category.direction == direction }
        transactions = filtered
        total = filtered.reduce(0) { $0 + $1.amount }
    }
}

// MARK: - Date Extension
private extension Date {
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }

    func endOfDay() -> Date {
        Calendar.current.date(
            bySettingHour: 23, minute: 59, second: 59, of: self
        )!
    }
}
