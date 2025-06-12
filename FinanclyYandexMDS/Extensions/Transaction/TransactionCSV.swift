import Foundation

extension Transaction {

    // MARK: - CSV Parsing with error handling
    static func parseCSV(from csv: String) -> [Transaction] {
        let lines = csv.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard lines.count > 1 else { return [] }

        let fmt = ISO8601DateFormatter()
        var result: [Transaction] = []

        for (index, line) in lines.dropFirst().enumerated() {
            let cols = line.components(separatedBy: ",")
            guard cols.count >= 14 else {
                print("Line \(index + 2): not enough columns (\(cols.count))")
                continue
            }

            guard let id = Int(cols[0]) else {
                print("Line \(index + 2): invalid id: \(cols[0])")
                continue
            }

            guard let accId = Int(cols[1]) else {
                print("Line \(index + 2): invalid account id: \(cols[1])")
                continue
            }

            let accName = cols[2]
            if accName.isEmpty {
                print("Line \(index + 2): empty account name")
                continue
            }

            guard let accBalance = Decimal(string: cols[3]) else {
                print("Line \(index + 2): invalid balance: \(cols[3])")
                continue
            }

            let accCurrency = cols[4]
            if accCurrency.isEmpty {
                print("Line \(index + 2): empty currency")
                continue
            }

            guard let catId = Int(cols[5]) else {
                print("Line \(index + 2): invalid category id: \(cols[5])")
                continue
            }

            let catName = cols[6]
            if catName.isEmpty {
                print("Line \(index + 2): empty category name")
                continue
            }

            let catEmojiStr = cols[7]
            guard let catEmoji = catEmojiStr.first else {
                print("Line \(index + 2): missing emoji")
                continue
            }

            guard let catIsIncome = Bool(cols[8]) else {
                print("Line \(index + 2): invalid isIncome value: \(cols[8])")
                continue
            }

            guard let amt = Decimal(string: cols[9]) else {
                print("Line \(index + 2): invalid amount: \(cols[9])")
                continue
            }

            guard let txDate = fmt.date(from: cols[10]) else {
                print("Line \(index + 2): invalid transaction date: \(cols[10])")
                continue
            }
            

            // Optional comment
            let comment = cols[11].isEmpty ? nil : cols[11]

            guard let cDate = fmt.date(from: cols[12]) else {
                print("Line \(index + 2): invalid createdAt date: \(cols[12])")
                continue
            }

            guard let uDate = fmt.date(from: cols[13]) else {
                print("Line \(index + 2): invalid updatedAt date: \(cols[13])")
                continue
            }

            // Init Category and AccountBrief
            let account = BankAccount(id: accId, name: accName, balance: accBalance, currency: accCurrency)
            let category = Category(id: catId, name: catName, emoji: catEmoji, isIncome: catIsIncome)

            let tx = Transaction(id: id, account: account, category: category, amount: amt,
                                 transactionDate: txDate, comment: comment,
                                 createdAt: cDate, updatedAt: uDate)
            result.append(tx)
        }

        return result
    }

    // MARK: - CSV Line Generation
    var csvLine: String {
        let fmt = ISO8601DateFormatter()
        return [
            "\(id)",
            "\(account.id)",
            account.name,
            "\(account.balance)",
            account.currency,
            "\(category.id)",
            category.name,
            String(category.emoji),
            "\(category.isIncome)",
            "\(amount)",
            fmt.string(from: transactionDate),
            comment ?? "",
            fmt.string(from: createdAt),
            fmt.string(from: updatedAt)
        ].joined(separator: ",")
    }
}
