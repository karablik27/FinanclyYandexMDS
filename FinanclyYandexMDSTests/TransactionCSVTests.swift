import XCTest
@testable import FinanclyYandexMDS

// Не  трбовалось для дз, чисто для себя проверить
final class TransactionCSVTests: XCTestCase {

    private let iso = ISO8601DateFormatter()

    private var transaction: Transaction {
        let baseDate = iso.date(from: "2025-06-11T16:12:34Z")!

        let account = BankAccount(
            id: 1,
            name: "Основной счёт",
            balance: Decimal(string: "1000.00")!,
            currency: "RUB"
        )

        let category = Category(id: 1, name: "Зарплата", emoji: "💰", isIncome: true)

        return Transaction(
            id: 42,
            account: account,
            category: category,
            amount: Decimal(string: "500.00")!,
            transactionDate: baseDate,
            comment: "Тестовая запись",
            createdAt: baseDate,
            updatedAt: baseDate
        )
    }

    func test_csvLine_hasCorrectStructure() {
        let csv = transaction.csvLine
        let columns = csv.components(separatedBy: ",")

        XCTAssertEqual(columns.count, 14)
        XCTAssertEqual(columns[0], "42")
        XCTAssertEqual(columns[2], "Основной счёт")
        XCTAssertEqual(columns[6], "Зарплата")
        XCTAssertEqual(columns[7], "💰")
        XCTAssertEqual(columns[8], "true")
        XCTAssertEqual(columns[11], "Тестовая запись")
    }

    func test_parseCSV_singleLine() {
        let csvHeader = [
            "id", "accountId", "accountName", "accountBalance", "accountCurrency",
            "categoryId", "categoryName", "categoryEmoji", "isIncome",
            "amount", "transactionDate", "comment", "createdAt", "updatedAt"
        ].joined(separator: ",")

        let csvLine = transaction.csvLine
        let csv = [csvHeader, csvLine].joined(separator: "\n")

        let parsed = Transaction.parseCSV(from: csv)

        XCTAssertEqual(parsed.count, 1)
        let tx = parsed[0]

        XCTAssertEqual(tx.id, 42)
        XCTAssertEqual(tx.account.name, "Основной счёт")
        XCTAssertEqual(tx.category.emoji, "💰")
        XCTAssertEqual(tx.amount, Decimal(string: "500.00"))
        XCTAssertEqual(tx.comment, "Тестовая запись")
        XCTAssertEqual(iso.string(from: tx.transactionDate), iso.string(from: transaction.transactionDate))
    }

    func test_parseCSV_emptyLinesIgnored() {
        let csv = """
        id,accountId,accountName,accountBalance,accountCurrency,categoryId,categoryName,categoryEmoji,isIncome,amount,transactionDate,comment,createdAt,updatedAt

        """

        let result = Transaction.parseCSV(from: csv)
        XCTAssertTrue(result.isEmpty)
    }

    func test_roundTrip_csvLine_parseCSV() {
        let original = transaction
        let header = "id,accountId,accountName,accountBalance,accountCurrency,categoryId,categoryName,categoryEmoji,isIncome,amount,transactionDate,comment,createdAt,updatedAt"
        let csv = [header, original.csvLine].joined(separator: "\n")

        let parsed = Transaction.parseCSV(from: csv)
        XCTAssertEqual(parsed.count, 1)

        let restored = parsed[0]
        XCTAssertEqual(restored.id, original.id)
        XCTAssertEqual(restored.account.name, original.account.name)
        XCTAssertEqual(restored.category.name, original.category.name)
        XCTAssertEqual(restored.amount, original.amount)
        XCTAssertEqual(restored.comment, original.comment)
    }
}
