import Foundation
import SwiftData

@MainActor
final class BankAccountsLocalSwiftDataStore: BankAccountsLocalStore {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    func saveAll(_ accounts: [BankAccount]) async throws {
        let context = container.mainContext
        for account in accounts {
            let entity = AccountEntity(
                id: account.id,
                name: account.name,
                balance: account.balance,
                currency: account.currency
            )
            context.insert(entity)
        }
        try context.save()
    }

    func getAll() async throws -> [BankAccount] {
        let context = container.mainContext
        let entities = try context.fetch(FetchDescriptor<AccountEntity>())

        let accounts: [BankAccount] = entities.map { entity in
            BankAccount(
                id: entity.id,
                name: entity.name,
                balance: entity.balance,
                currency: entity.currency
            )
        }

        return accounts
    }

}
