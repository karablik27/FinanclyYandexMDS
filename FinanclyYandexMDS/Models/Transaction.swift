import Foundation

// MARK: Transaction Model
struct Transaction: Codable {
    let id: Int
    let account: BankAccount
    let category: FinanclyYandexMDS.Category
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date
}

