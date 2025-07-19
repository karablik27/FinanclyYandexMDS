import Foundation

struct Transaction: Codable {
    let id: Int
    let account: BankAccount
    let category: Category
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date

    private enum CodingKeys: String, CodingKey {
        case id, account, category, amount, transactionDate, comment, createdAt, updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        account = try container.decode(BankAccount.self, forKey: .account)
        category = try container.decode(Category.self, forKey: .category)

        let amountString = try container.decode(String.self, forKey: .amount)
        guard let decimalAmount = Decimal(string: amountString) else {
            throw DecodingError.dataCorruptedError(forKey: .amount, in: container, debugDescription: "Invalid decimal amount string.")
        }
        amount = decimalAmount

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let transactionDateString = try container.decode(String.self, forKey: .transactionDate)
        let createdAtString       = try container.decode(String.self, forKey: .createdAt)
        let updatedAtString       = try container.decode(String.self, forKey: .updatedAt)

        guard let txDate = formatter.date(from: transactionDateString) else {
            throw DecodingError.dataCorruptedError(forKey: .transactionDate, in: container, debugDescription: "Invalid date string.")
        }
        guard let created = formatter.date(from: createdAtString) else {
            throw DecodingError.dataCorruptedError(forKey: .createdAt, in: container, debugDescription: "Invalid date string.")
        }
        guard let updated = formatter.date(from: updatedAtString) else {
            throw DecodingError.dataCorruptedError(forKey: .updatedAt, in: container, debugDescription: "Invalid date string.")
        }

        transactionDate = txDate
        createdAt = created
        updatedAt = updated

        comment = try container.decodeIfPresent(String.self, forKey: .comment)
    }

    func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(account, forKey: .account)
        try container.encode(category, forKey: .category)
        try container.encode("\(amount)", forKey: .amount)

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        try container.encode(formatter.string(from: transactionDate), forKey: .transactionDate)
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(formatter.string(from: updatedAt), forKey: .updatedAt)
        try container.encodeIfPresent(comment, forKey: .comment)
    }
}

extension Transaction {
    init(
        id: Int,
        account: BankAccount,
        category: Category,
        amount: Decimal,
        transactionDate: Date,
        comment: String?,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.account = account
        self.category = category
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension Transaction {
    init(from request: TransactionRequestBody, id: Int) {
        self.init(
            id: id,
            account: .dummy,
            category: .dummy,
            amount: Decimal(string: request.amount) ?? 0,
            transactionDate: ISO8601DateFormatter().date(from: request.transactionDate) ?? Date(),
            comment: request.comment,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
