import Foundation

// MARK: - TransactionsListViewModel

@MainActor
final class TransactionsListViewModel: ObservableObject {
    
    // MARK: - Published Properties

    @Published var transactions: [Transaction] = []
    @Published var total: Decimal = 0

    // MARK: - Private Properties
    private let direction: Direction
    private let service = TransactionsService()

    // MARK: - Init
    init(direction: Direction) {
        self.direction = direction
        Task {
            await loadToday()
        }
    }

    // MARK: - Data Loading
    func loadToday() async {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let all = await service.getTransactions(from: startOfDay, to: tomorrow)

        let filtered = all.filter { tx in
            let d = tx.transactionDate
            return d >= startOfDay
                && d < tomorrow
                && tx.category.direction == direction
        }

        self.transactions = filtered
        self.total = filtered.reduce(0) { $0 + $1.amount }
    }
}
