import Foundation

/// Mock implementation of the transactions service
final class TransactionsService {
    
    // MARK: - Mock Data
    private var transactions: [Transaction] = {
        let calendar = Calendar.current
        let now = Date()
        let account = BankAccount(
            id: 1,
            name: "Основной счёт",
            balance: Decimal(string: "5000")!,
            currency: "RUB"
        )

        // Категории
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
            let amount = Decimal(string: "\(1000 * (i+1))")!
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
            let amount = Decimal(string: "\(500 * (i+1))")!
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
    }()
    
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
    }

    // MARK: - Updating
    func updateTransaction(_ updated: Transaction) async {
        guard let idx = transactions.firstIndex(where: { $0.id == updated.id }) else { return }
        transactions[idx] = updated
    }

    // MARK: - Deleting
    func deleteTransaction(id: Int) async {
        transactions.removeAll { $0.id == id }
    }
}
