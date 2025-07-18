import Foundation

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
    init(mode: AddTransactionForm, client: NetworkClient, accountId: Int) {
        self.mode = mode
        self.txService = TransactionsService(client: client)
        self.accService = BankAccountsService(client: client)
        self.catService = CategoriesService(client: client)
        self.accountId = accountId

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

        let requestBody = TransactionRequestBody(
            accountId: accountId,
            categoryId: cat.id,
            amount: amount,
            transactionDate: date,
            comment: comment
        )

        do {
            if mode.isCreate {
                _ = try await txService.createTransaction(requestBody)
            } else if let id = original?.id {
                _ = try await txService.updateTransaction(id: id, with: requestBody)
            }
        } catch {
            print("Ошибка сохранения транзакции: \(error.localizedDescription)")
        }
    }

    // MARK: - Delete
    func delete() async {
        guard case .edit(let tx) = mode else { return }
        do {
            try await txService.deleteTransaction(id: tx.id)
        } catch {
            print("Ошибка удаления транзакции: \(error.localizedDescription)")
        }
    }
}
