import Foundation
import Combine
import SwiftData
import PieChart

@MainActor
final class AnalysisViewModel: ObservableObject {
    // MARK: - Входные параметры
    let service: TransactionsService
    let direction: Direction
    let accountId: Int
    let modelContainer: ModelContainer

    // MARK: - Публичные @Published
    @Published var transactions: [Transaction] = []
    @Published var total: Decimal = 0
    @Published var startDate: Date {
        didSet { load() }
    }
    @Published var endDate: Date {
        didSet { load() }
    }
    @Published var isLoading: Bool = false
    @Published var alertMessage: String?

    var sortOption: SortOption = .date {
        didSet { sortTransactions() }
    }

    var onUpdate: (() -> Void)?
    var cancellables: Set<AnyCancellable> = []

    // MARK: - Инициализация
    init(client: NetworkClient, accountId: Int, direction: Direction, modelContainer: ModelContainer) {
        self.accountId = accountId
        self.direction = direction
        self.modelContainer = modelContainer

        let localStore: TransactionsLocalStore = TransactionsSwiftDataStore(container: modelContainer)
        let backupSchema = Schema([TransactionBackupModel.self])
        let backupContainer = try? ModelContainer(for: backupSchema)
        let backupStore: TransactionsBackupStore? = backupContainer.map { TransactionsBackupStore(container: $0) }

        self.service = TransactionsService(
            client: client,
            localStore: localStore,
            backupStore: backupStore
        )

        let now = Date()
        self.endDate = now.endOfDay()
        self.startDate = Calendar.current.date(byAdding: .month, value: -1, to: now)!.startOfDay()

        load()
    }

    // MARK: - Загрузка транзакций
    func load() {
        isLoading = true
        Task {
            defer { isLoading = false }

            do {
                let all = try await service.getTransactions(
                    forAccount: accountId,
                    from: startDate.startOfDay(),
                    to: endDate.endOfDay()
                )

                let filtered = all.filter { $0.category.direction == direction }

                self.transactions = filtered
                self.total = filtered.reduce(Decimal(0)) { $0 + $1.amount }

                sortTransactions()
            } catch {
                alertMessage = "Не удалось загрузить данные: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Сортировка
    private func sortTransactions() {
        switch sortOption {
        case .date:
            transactions.sort(by: { $0.transactionDate > $1.transactionDate })
        case .amount:
            transactions.sort(by: { $0.amount > $1.amount })
        }
        onUpdate?()
    }
}

extension AnalysisViewModel {
    var chartEntities: [Entity] {
        let categorySums = transactions.reduce(into: [String: Decimal]()) { result, tx in
            result[tx.category.name, default: 0] += tx.amount
        }

        let sorted = categorySums
            .map { Entity(value: $0.value, label: $0.key) }
            .sorted { $0.value > $1.value }

        if sorted.count > 5 {
            let top5 = sorted.prefix(5)
            let others = sorted.dropFirst(5).reduce(Decimal(0)) { $0 + $1.value }
            return Array(top5) + [Entity(value: others, label: "Остальные")]
        } else {
            return sorted
        }
    }
}
