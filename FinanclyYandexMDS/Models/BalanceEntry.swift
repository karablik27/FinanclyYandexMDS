import Foundation

public struct BalanceEntry: Identifiable, Equatable {
    public let id = UUID()
    public let date: Date
    public let balance: Decimal

    public init(date: Date, balance: Decimal) {
        self.date = date
        self.balance = balance
    }

    var doubleBalance: Double {
        NSDecimalNumber(decimal: balance).doubleValue
    }
}
