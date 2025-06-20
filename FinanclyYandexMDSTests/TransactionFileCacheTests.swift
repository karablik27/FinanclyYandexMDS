import XCTest
@testable import FinanclyYandexMDS

// Не  трбовалось для дз, чисто для себя проверить
final class TransactionFileCacheTests: XCTestCase {

    private let iso = ISO8601DateFormatter()

    private func tempFileURL() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("test_transactions.json")
    }

    private func testTransactions() -> [Transaction] {
        let baseDate = iso.date(from: "2025-06-11T16:12:34Z")!

        let account = BankAccount(
            id: 1,
            name: "Основной счёт",
            balance: Decimal(string: "1000.00")!,
            currency: "RUB"
        )
        let salaryCategory = Category(id: 1, name: "Зарплата", emoji: "💰", isIncome: true)
        let foodCategory = Category(id: 2, name: "Ресторан", emoji: "🍽️", isIncome: false)

        return [
            Transaction(
                id: 1,
                account: account,
                category: salaryCategory,
                amount: Decimal(string: "500.00")!,
                transactionDate: baseDate.addingTimeInterval(-3600),
                comment: "Зарплата за месяц",
                createdAt: baseDate.addingTimeInterval(-3600),
                updatedAt: baseDate.addingTimeInterval(-3600)
            ),
            Transaction(
                id: 2,
                account: account,
                category: foodCategory,
                amount: Decimal(string: "150.00")!,
                transactionDate: baseDate,
                comment: "Ужин",
                createdAt: baseDate,
                updatedAt: baseDate
            )
        ]
    }

    func test_saveAndLoad_transactionsPreserved() throws {
        let cache = TransactionsFileCache()
        let txs = testTransactions()
        txs.forEach { cache.add($0) }

        let fileURL = tempFileURL()
        try cache.save(to: fileURL)

        let loadedCache = TransactionsFileCache()
        try loadedCache.load(from: fileURL)

        XCTAssertEqual(loadedCache.transactions.count, txs.count, "Количество транзакций должно совпадать")

        for (expected, actual) in zip(txs, loadedCache.transactions) {
            XCTAssertEqual(expected.id, actual.id)
            XCTAssertEqual(expected.account.name, actual.account.name)
            XCTAssertEqual(expected.category.name, actual.category.name)
            XCTAssertEqual(expected.amount, actual.amount)
            XCTAssertEqual(expected.comment, actual.comment)
            XCTAssertEqual(iso.string(from: expected.transactionDate),iso.string(from: actual.transactionDate))
        }
    }

    func test_load_deduplicatesById() throws {
        let fileURL = tempFileURL()

        let tx = testTransactions()[0]
        let dupes = [tx, tx]

        let raw = dupes.map { $0.jsonObject }
        let data = try JSONSerialization.data(withJSONObject: raw, options: [])
        try data.write(to: fileURL)

        let cache = TransactionsFileCache()
        try cache.load(from: fileURL)

        XCTAssertEqual(cache.transactions.count, 1, "Должна остаться только одна транзакция с уникальным id")
    }
}
