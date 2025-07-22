import SwiftData

@MainActor
final class StorageSwitcher {
    static func makeTransactionStore(container: ModelContainer) -> TransactionsLocalStore {
        switch StorageMode.current {
        case .swiftdata:
            return TransactionsSwiftDataStore(container: container)
        case .coredata:
            return TransactionsCoreDataStore()
        }
    }
}
