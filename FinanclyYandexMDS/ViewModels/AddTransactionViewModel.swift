import Foundation
import SwiftData

@MainActor
final class AddTransactionViewModel: ObservableObject {
    // MARK: - Published
    @Published var category: Category?
    @Published var amountString: String = ""
    @Published var date: Date = Date()
    @Published var comment: String = ""
    @Published var showCategoryPicker = false
    @Published var categories: [Category] = []

    // MARK: - Dependencies
    private let txService: TransactionsService
    private let accService: BankAccountsService
    private let catService: CategoriesService
    let mode: AddTransactionForm
    private var original: Transaction?
    private let accountId: Int

    // MARK: - Init
    init(mode: AddTransactionForm, client: NetworkClient, accountId: Int, modelContainer: ModelContainer) {
        self.mode = mode
        self.accountId = accountId

        let localTxStore = TransactionsSwiftDataStore(container: modelContainer)
        let backupSchema = Schema([TransactionBackupModel.self])
        let backupContainer = try? ModelContainer(for: backupSchema)
        let backupStore = backupContainer.map { TransactionsBackupStore(container: $0) }

        self.txService = TransactionsService(
            client: client,
            localStore: localTxStore,
            backupStore: backupStore
        )
        self.accService = BankAccountsService(client: client)
        self.catService = CategoriesService(
            client: client,
            localStore: CategoriesLocalSwiftDataStore(container: modelContainer)
        )

        if case .edit(let tx) = mode {
            original = tx
            category = tx.category
            amountString = tx.amount.description
            date = tx.transactionDate
            comment = tx.comment ?? ""
        }

        Task {
            do {
                categories = try await catService.byDirection(mode.direction)
            } catch {
                print("Ошибка загрузки категорий: \(error.localizedDescription)")
                do {
                    categories = try await catService.loadFromLocal().filter { $0.direction == mode.direction }
                } catch {
                    print("Ошибка локальной загрузки категорий: \(error.localizedDescription)")
                }
            }
        }
    }

    var direction: Direction { mode.direction }

    var canSave: Bool {
        category != nil &&
        Decimal(string: normalizedAmountString) != nil
    }

    private var normalizedAmountString: String {
        amountString.replacingOccurrences(of: Locale.current.decimalSeparator ?? ".", with: ".")
    }

    // MARK: - Save
    func save() async {
        guard canSave,
              let cat = category,
              let amount = Decimal(string: normalizedAmountString)
        else { return }

        let body = TransactionRequestBody(
            accountId: accountId,
            categoryId: cat.id,
            amount: amount,
            transactionDate: date,
            comment: comment
        )

        do {
            if mode.isCreate {
                _ = try await txService.createTransaction(body)
            } else if let id = original?.id {
                _ = try await txService.updateTransaction(id: id, with: body)
            }
        } catch {
            print("⚠️ Ошибка сохранения: \(error.localizedDescription)")
        }
    }

    // MARK: - Delete
    func delete() async {
        guard case .edit(let tx) = mode else { return }

        do {
            try await txService.deleteTransaction(id: tx.id)
        } catch {
            print("⚠️ Ошибка удаления: \(error.localizedDescription)")
        }
    }
}
