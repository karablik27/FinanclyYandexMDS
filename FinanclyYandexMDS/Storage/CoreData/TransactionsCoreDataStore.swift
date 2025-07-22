import Foundation
import CoreData

final class TransactionsCoreDataStore: TransactionsLocalStore {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.context) {
        self.context = context
    }

    func getAll() async throws -> [Transaction] {
        let request: NSFetchRequest<CDTransaction> = CDTransaction.fetchRequest()

        let cdItems = try context.fetch(request)
        return cdItems.compactMap { $0.toTransaction() }
    }

    func create(_ transaction: Transaction) async throws {
        let cd = CDTransaction(context: context)
        cd.fill(with: transaction)
        try context.save()
    }

    func delete(by id: Int) async throws {
        let request: NSFetchRequest<CDTransaction> = CDTransaction.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        if let item = try context.fetch(request).first {
            context.delete(item)
            try context.save()
        }
    }

    func replaceAll(_ transactions: [Transaction]) async throws {
        let request: NSFetchRequest<CDTransaction> = CDTransaction.fetchRequest()
        let all = try context.fetch(request)
        all.forEach(context.delete)

        transactions.forEach { tx in
            let cd = CDTransaction(context: context)
            cd.fill(with: tx)
        }

        try context.save()
    }
    
    func update(_ transaction: Transaction) async throws {
        let request: NSFetchRequest<CDTransaction> = CDTransaction.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", transaction.id)

        if let item = try context.fetch(request).first {
            item.fill(with: transaction)
            try context.save()
        } else {
            throw NSError(domain: "UpdateError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Transaction not found"])
        }
    }

    func get(by id: Int) async throws -> Transaction? {
        let request: NSFetchRequest<CDTransaction> = CDTransaction.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)

        guard let item = try context.fetch(request).first else {
            return nil
        }

        return item.toTransaction()
    }

}


import CoreData

extension CDTransaction {
    func toTransaction() -> Transaction? {
        guard let transactionDate,
              let createdAt,
              let updatedAt,
              let nsAmount = amount as? NSDecimalNumber else {
            return nil
        }

        let amountDecimal = nsAmount.decimalValue

        return Transaction(
            id: Int(id),
            account: BankAccount(
                id: Int(accountId),
                name: "",
                balance: Decimal(string: "0") ?? 0,
                currency: "RUB"
            ),
            category: Category(
                id: Int(categoryId),
                name: "",
                emoji: "💰".first ?? "💰",
                isIncome: true
            ),
            amount: amountDecimal,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    func fill(with tx: Transaction) {
        id = Int64(tx.id)
        accountId = Int64(tx.account.id)
        categoryId = Int64(tx.category.id)
        amount = NSDecimalNumber(decimal: tx.amount)
        transactionDate = tx.transactionDate
        comment = tx.comment
        createdAt = tx.createdAt
        updatedAt = tx.updatedAt
    }
}

