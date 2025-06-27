import XCTest
@testable import FinanclyYandexMDS

final class TransactionJSONTests: XCTestCase {
    
    // MARK: - Constants
    private let iso: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private lazy var baseDate: Date = {
        iso.date(from: "2025-06-11T16:12:34.235Z")!
    }()

    // MARK: - Shared Test Data
    private var account: BankAccount {
        BankAccount(
            id: 1,
            name: "Основной счёт",
            balance: Decimal(string: "1000.00")!,
            currency: "RUB"
        )
    }

    private var salaryCategory: FinanclyYandexMDS.Category {
        Category(id: 1, name: "Зарплата", emoji: "💰", isIncome: true)
    }

    private var foodCategory: FinanclyYandexMDS.Category {
        Category(id: 2, name: "Ресторан", emoji: "🍽️", isIncome: false)
    }

    // MARK: - Fixtures
    private func salaryTransaction() -> Transaction {
        Transaction(
            id: 1,
            account: account,
            category: salaryCategory,
            amount: Decimal(string: "500.00")!,
            transactionDate: baseDate.addingTimeInterval(-3600),
            comment: "Зарплата за месяц",
            createdAt: baseDate.addingTimeInterval(-3600),
            updatedAt: baseDate.addingTimeInterval(-3600)
        )
    }

    private func foodTransaction() -> Transaction {
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
    }

    // MARK: - Tests

    func test_salaryTransaction_JSONRoundTrip() throws {
        let tx = salaryTransaction()
        let obj = tx.jsonObject

        XCTAssertTrue(JSONSerialization.isValidJSONObject(obj), "jsonObject must be valid JSON")

        let parsed = try Transaction.parse(jsonObject: obj)

        XCTAssertEqual(parsed.id, tx.id)
        XCTAssertEqual(parsed.account.name, tx.account.name)
        XCTAssertEqual(parsed.category.name, "Зарплата")
        XCTAssertTrue(parsed.category.isIncome)
        XCTAssertEqual(parsed.amount, tx.amount)
        XCTAssertEqual(parsed.comment, tx.comment)
        XCTAssertEqual(iso.string(from: parsed.transactionDate), iso.string(from: tx.transactionDate))
    }

    func test_foodTransaction_JSONRoundTrip() throws {
        let tx = foodTransaction()
        let obj = tx.jsonObject

        XCTAssertTrue(JSONSerialization.isValidJSONObject(obj), "jsonObject must be valid JSON")

        let parsed = try Transaction.parse(jsonObject: obj)

        XCTAssertEqual(parsed.id, tx.id)
        XCTAssertEqual(parsed.account.name, tx.account.name)
        XCTAssertEqual(parsed.category.name, "Ресторан")
        XCTAssertFalse(parsed.category.isIncome)
        XCTAssertEqual(parsed.amount, tx.amount)
        XCTAssertEqual(parsed.comment, tx.comment)
        XCTAssertEqual(iso.string(from: parsed.transactionDate), iso.string(from: tx.transactionDate))
    }

    func test_parse_invalidInput_throwsError() {
        XCTAssertThrowsError(try Transaction.parse(jsonObject: "not a dict"))
        XCTAssertThrowsError(try Transaction.parse(jsonObject: ["bad": "data"]))
    }
}
