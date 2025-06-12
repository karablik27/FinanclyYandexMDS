import Foundation

extension Transaction {
    
    // TransactionResponse
    var jsonObject: Any {
        return [
            "id": id,
            "account": [
                "id": account.id,
                "name": account.name,
                "balance": "\(account.balance)",
                "currency": account.currency
            ],
            "category": [
                "id": category.id,
                "name": category.name,
                "emoji": String(category.emoji),
                "isIncome": category.isIncome
            ],
            "amount": "\(amount)",
            "transactionDate": ISO8601DateFormatter().string(from: transactionDate),
            "comment": comment ?? "",
            "createdAt": ISO8601DateFormatter().string(from: createdAt),
            "updatedAt": ISO8601DateFormatter().string(from: updatedAt)
        ]
    }

    static func parse(jsonObject: Any) -> Transaction? {
        
        guard let dict = jsonObject as? [String: Any] else {
            print("JSONObject is not a dictionary.")
            return nil
        }

        // First field
        guard let id = dict["id"] as? Int else {
            print("Missing or invalid 'id'.")
            return nil
        }

        // Account
        guard let accountDict = dict["account"] as? [String: Any],
              let accountId = accountDict["id"] as? Int,
              let accountName = accountDict["name"] as? String,
              let accountBalanceString = accountDict["balance"] as? String,
              let accountBalance = Decimal(string: accountBalanceString),
              let accountCurrency = accountDict["currency"] as? String else {
            print("Error parsing AccountBrief.")
            return nil
        }

        // Category
        guard let categoryDict = dict["category"] as? [String: Any],
              let categoryId = categoryDict["id"] as? Int,
              let categoryName = categoryDict["name"] as? String,
              let categoryEmojiString = categoryDict["emoji"] as? String,
              let categoryEmoji = categoryEmojiString.first,
              let categoryIsIncome = categoryDict["isIncome"] as? Bool else {
            print("Error parsing Category.")
            return nil
        }

        // Other fields
        guard let amountString = dict["amount"] as? String,
              let amount = Decimal(string: amountString) else {
            print("Invalid or missing 'amount' field.")
            return nil
        }

        let formatter = ISO8601DateFormatter()

        guard let transactionDateStr = dict["transactionDate"] as? String,
              let transactionDate = formatter.date(from: transactionDateStr) else {
            print("Invalid 'transactionDate' field.")
            return nil
        }

        guard let createdAtStr = dict["createdAt"] as? String,
              let createdAt = formatter.date(from: createdAtStr) else {
            print("Invalid 'createdAt' field.")
            return nil
        }

        guard let updatedAtStr = dict["updatedAt"] as? String,
              let updatedAt = formatter.date(from: updatedAtStr) else {
            print("Invalid 'updatedAt' field.")
            return nil
        }

        // Optional comment
        let comment = dict["comment"] as? String

        // Init Category and AccountBrief
        let account = BankAccount(id: accountId, name: accountName, balance: accountBalance, currency: accountCurrency)
        let category = Category(id: categoryId, name: categoryName, emoji: categoryEmoji, isIncome: categoryIsIncome)

        return Transaction(
            id: id,
            account: account,
            category: category,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
