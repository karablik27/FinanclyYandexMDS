import Foundation

final class TransactionsService {
    
    // MARK: - Dependencies
    private let fileCache: TransactionsFileCache
    private let fileURL: URL
    private(set) var transactions: [Transaction] = []

    // MARK: - Init
    init(fileName: String = "transactions") {
        self.fileCache = TransactionsFileCache()
        self.fileURL = TransactionsFileCache.defaultFileURL(fileName: fileName)

        // Пытаемся загрузить из файла
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try fileCache.load(from: fileURL)
                self.transactions = fileCache.transactions
            } catch {
                print("⚠️ Failed to load transactions from file: \(error)")
                self.transactions = []
            }
        } else {
            // Файл отсутствует — создаём мок-данные и сохраняем
            self.transactions = Self.generateMockTransactions()
            for tx in transactions {
                fileCache.add(tx)
            }
            try? fileCache.save(to: fileURL)
        }
    }

    // MARK: - Fetching
    func getTransactions(from start: Date, to end: Date) async -> [Transaction] {
        return transactions.filter {
            $0.transactionDate >= start && $0.transactionDate <= end
        }
    }

    // MARK: - Creating
    func createTransaction(_ new: Transaction) async {
        guard !transactions.contains(where: { $0.id == new.id }) else {
            print("Transaction with id \(new.id) already exists. Skipping.")
            return
        }
        transactions.append(new)
        fileCache.add(new)
        try? fileCache.save(to: fileURL)
    }

    // MARK: - Updating
    func updateTransaction(_ updated: Transaction) async {
        guard let idx = transactions.firstIndex(where: { $0.id == updated.id }) else { return }
        transactions[idx] = updated
        fileCache.replaceAll(transactions)
        try? fileCache.save(to: fileURL)
    }

    // MARK: - Deleting
    func deleteTransaction(id: Int) async {
        transactions.removeAll { $0.id == id }
        fileCache.remove(withId: id)
        try? fileCache.save(to: fileURL)
    }
    
    func refresh() {
        do {
            try fileCache.load(from: fileURL)
            self.transactions = fileCache.transactions
        } catch {
            print("⚠️ Failed to refresh transactions from file: \(error)")
        }
    }

    // MARK: - Mocks
    private static func generateMockTransactions() -> [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        let account = BankAccount(
            id: 1,
            name: "Основной счёт",
            balance: Decimal(string: "5000")!,
            currency: "RUB"
        )

        let incomeCategories: [Category] = [
            .init(id: 100, name: "Зарплата", emoji: "💼", isIncome: true),
            .init(id: 101, name: "Бонус", emoji: "🎁", isIncome: true),
        ]
        let outcomeCategories: [Category] = [
            .init(id: 1, name: "Продукты", emoji: "🍏", isIncome: false),
            .init(id: 2, name: "Кофе", emoji: "☕️", isIncome: false),
            .init(id: 3, name: "Транспорт", emoji: "🚕", isIncome: false),
            .init(id: 4, name: "Ресторан", emoji: "🍽️", isIncome: false),
        ]

        var txs: [Transaction] = []

        for i in 0..<5 {
            let date = calendar.date(byAdding: .day, value: -i, to: now)!
            let category = incomeCategories[i % incomeCategories.count]
            let amount = Decimal(string: "\(1000 * (i + 1))")!
            txs.append(
                Transaction(
                    id: 1000 + i,
                    account: account,
                    category: category,
                    amount: amount,
                    transactionDate: date,
                    comment: i % 2 == 0 ? "Периодический платёж" : nil,
                    createdAt: date,
                    updatedAt: date
                )
            )
        }

        for i in 0..<10 {
            let date = calendar.date(byAdding: .day, value: -i, to: now)!
            let category = outcomeCategories[i % outcomeCategories.count]
            let amount = Decimal(string: "\(500 * (i + 1))")!
            let comment: String? = (i % 3 == 0) ? "Тестовый комментарий" : nil
            txs.append(
                Transaction(
                    id: 2000 + i,
                    account: account,
                    category: category,
                    amount: amount,
                    transactionDate: date,
                    comment: comment,
                    createdAt: date,
                    updatedAt: date
                )
            )
        }

        return txs.shuffled()
    }
}
