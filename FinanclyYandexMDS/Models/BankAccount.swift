import Foundation

struct BankAccount: Codable {

    // MARK: – Stored Properties
    let id: Int
    let userId: Int?
    let name: String
    let balance: Decimal
    let currency: String
    let createdAt: Date?
    let updatedAt: Date?

    // MARK: – Public Initializers
    init(id: Int, userId: Int, name: String,
         balance: Decimal, currency: String,
         createdAt: Date, updatedAt: Date) {
        self.id        = id
        self.userId    = userId
        self.name      = name
        self.balance   = balance
        self.currency  = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(id: Int, name: String,
         balance: Decimal, currency: String) {
        self.id = id
        self.name = name
        self.balance = balance
        self.currency = currency
        self.userId = nil
        self.createdAt = nil
        self.updatedAt = nil
    }

    // MARK: – Coding Keys
    private enum CodingKeys: String, CodingKey {
        case id, userId, name, balance, currency, createdAt, updatedAt
    }

    // MARK: – ISO‑8601 Helpers (с и без миллисекунд)
    private static let isoWithFraction: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    private static let isoNoFraction: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()
    private static func parseISO(_ s: String?) -> Date? {
        guard let s else { return nil }
        return isoWithFraction.date(from: s) ?? isoNoFraction.date(from: s)
    }

    // MARK: – Decoding
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        id     = try  c.decode(Int.self,  forKey: .id)
        userId = try? c.decode(Int.self,  forKey: .userId)
        name   = try  c.decode(String.self, forKey: .name)

        // balance как String (сервер всегда шлёт строку при /accounts)
        let balStr = try c.decode(String.self, forKey: .balance)
        guard let bal = Decimal(string: balStr,
                                locale: Locale(identifier: "en_US_POSIX"))
        else {
            throw DecodingError.dataCorruptedError(
                forKey: .balance, in: c,
                debugDescription: "Неверный формат Decimal: \(balStr)"
            )
        }
        balance  = bal
        currency = try c.decode(String.self, forKey: .currency)

        let createdStr  = try? c.decodeIfPresent(String.self, forKey: .createdAt)
        let updatedStr  = try? c.decodeIfPresent(String.self, forKey: .updatedAt)
        createdAt = BankAccount.parseISO(createdStr)
        updatedAt = BankAccount.parseISO(updatedStr)
    }

    // MARK: – Encoding
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)

        try c.encode(id,              forKey: .id)
        try c.encodeIfPresent(userId, forKey: .userId)
        try c.encode(name,            forKey: .name)
        try c.encode("\(balance)",    forKey: .balance)
        try c.encode(currency,        forKey: .currency)

        let f = BankAccount.isoWithFraction
        try c.encodeIfPresent(createdAt.map(f.string(from:)), forKey: .createdAt)
        try c.encodeIfPresent(updatedAt.map(f.string(from:)), forKey: .updatedAt)
    }
}

// MARK: – Dummy
extension BankAccount {
    static var dummy: BankAccount {
        BankAccount(id: -1, name: "Offline", balance: 0, currency: "RUB")
    }
}
