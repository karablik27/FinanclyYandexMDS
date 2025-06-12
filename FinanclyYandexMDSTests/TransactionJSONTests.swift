import XCTest
@testable import FinanclyYandexMDS

final class TransactionJSONTests: XCTestCase {
    
    // MARK: - Constants
    // ISO8601 formatter used for date comparisons
    private let iso = ISO8601DateFormatter()
    
    // Base date used in test transactions
    private let baseDate = ISO8601DateFormatter().date(from: "2025-06-11T16:12:34Z")!


    // MARK: - Shared Test Data
    // Mock bank account used in transactions
    private var account: BankAccount {
        BankAccount(
            id: 1,
            name: "Основной счёт",
            balance: Decimal(string: "1000.00")!,
            currency: "RUB"
        )
    }
    
    // Mock income category ("Зарплата")
    private var salaryCategory: FinanclyYandexMDS.Category {
        Category(id: 1, name: "Зарплата", emoji: "💰", isIncome: true)
    }

    // Mock outcome category ("Ресторан")
    private var foodCategory: FinanclyYandexMDS.Category {
        Category(id: 2, name: "Ресторан", emoji: "🍽️", isIncome: false)
    }

    // MARK: - Transaction Fixtures
    // Creates a test income transaction
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

    // Creates a test expense transaction
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

        // Ensure result is valid for JSON serialization
        XCTAssertTrue(JSONSerialization.isValidJSONObject(obj), "jsonObject must be valid JSON")

        // Parse back and verify correctness
        guard let parsed = Transaction.parse(jsonObject: obj) else {
            XCTFail("Failed to parse salary transaction")
            return
        }

        XCTAssertEqual(parsed.id, tx.id)
        XCTAssertEqual(parsed.account.name, tx.account.name)
        XCTAssertEqual(parsed.category.name, "Зарплата")
        XCTAssertEqual(parsed.category.isIncome, true)
        XCTAssertEqual(parsed.amount, tx.amount)
        XCTAssertEqual(parsed.comment, tx.comment)
        XCTAssertEqual(iso.string(from: parsed.transactionDate), iso.string(from: tx.transactionDate))
    }

    // Tests serialization and parsing of an expense transaction (food)
    func test_foodTransaction_JSONRoundTrip() throws {
        let tx = foodTransaction()
        let obj = tx.jsonObject

        // Ensure result is valid for JSON serialization
        XCTAssertTrue(JSONSerialization.isValidJSONObject(obj), "jsonObject must be valid JSON")

        // Parse back and verify correctness
        guard let parsed = Transaction.parse(jsonObject: obj) else {
            XCTFail("Failed to parse food transaction")
            return
        }

        XCTAssertEqual(parsed.id, tx.id)
        XCTAssertEqual(parsed.account.name, tx.account.name)
        XCTAssertEqual(parsed.category.name, "Ресторан")
        XCTAssertEqual(parsed.category.isIncome, false)
        XCTAssertEqual(parsed.amount, tx.amount)
        XCTAssertEqual(parsed.comment, tx.comment)
        XCTAssertEqual(iso.string(from: parsed.transactionDate), iso.string(from: tx.transactionDate))
    }

    // Tests that invalid or malformed input returns nil
    func test_parse_invalidInput_returnsNil() {
        XCTAssertNil(Transaction.parse(jsonObject: "not a dict"))
        XCTAssertNil(Transaction.parse(jsonObject: ["bad": "data"]))
    }
}
