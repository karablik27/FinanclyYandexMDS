import Foundation
import SwiftData

enum StorageMigrator {
    @MainActor
    static func migrateIfNeeded(container: ModelContainer) async throws {
        let previous = UserDefaults.standard.string(forKey: "previous_storage_method")
        let current = StorageMode.current.rawValue

        guard previous != current else { return }

        print("Выполняем миграцию: \(previous ?? "none") → \(current)")

        let oldStore: TransactionsLocalStore
        let newStore: TransactionsLocalStore

        if previous == "coredata" {
            oldStore = TransactionsCoreDataStore()
            newStore = TransactionsSwiftDataStore(container: container)
        } else {
            oldStore = TransactionsSwiftDataStore(container: container)
            newStore = TransactionsCoreDataStore()
        }

        let transactions = try await oldStore.getAll()
        try await newStore.replaceAll(transactions)

        print("Миграция завершена. Перенесено: \(transactions.count) операций")

        UserDefaults.standard.set(current, forKey: "previous_storage_method")
    }
}
