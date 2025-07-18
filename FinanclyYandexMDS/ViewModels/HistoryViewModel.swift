import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var transactions: [Transaction] = []
    @Published var total: Decimal = 0
    @Published var startDate: Date
    @Published var endDate: Date
    @Published var isLoading = false
    @Published var alertError: String?

    // MARK: - Private
    private let direction: Direction
    private let service: TransactionsService
    private let accountId: Int

    // MARK: - Init
    init(direction: Direction, client: NetworkClient, accountId: Int) {
        self.direction = direction
        self.service = TransactionsService(client: client)
        self.accountId = accountId

        let calendar = Calendar.current
        let now = Date()
        self.endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now)!
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
        self.startDate = calendar.startOfDay(for: oneMonthAgo)

        Task { await load() }
    }

    // MARK: - Load
    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let all = try await service.getTransactions(
                forAccount: accountId,
                from: startDate.startOfDay(),
                to: endDate.endOfDay()
            )
            let filtered = all.filter { $0.category.direction == direction }
            self.transactions = filtered
            self.total = filtered.reduce(0) { $0 + $1.amount }
        } catch {
            alertError = "Не удалось загрузить операции: \(error.localizedDescription)"
        }
    }
}
