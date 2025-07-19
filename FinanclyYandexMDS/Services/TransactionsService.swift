import Foundation

final class TransactionsService {
    // MARK: - Dependencies
    let client: NetworkClient
    private let fileCache: TransactionsFileCache
    private let fileURL: URL
    private let localStore: TransactionsLocalStore?
    private let backupStore: TransactionsBackupStore?

    // MARK: - Init
    init(
        client: NetworkClient,
        localStore: TransactionsLocalStore? = nil,
        backupStore: TransactionsBackupStore? = nil,
        fileName: String = "transactions"
    ) {
        self.client = client
        self.localStore = localStore
        self.backupStore = backupStore
        self.fileCache = TransactionsFileCache()
        self.fileURL = TransactionsFileCache.defaultFileURL(fileName: fileName)

        try? fileCache.load(from: fileURL)
    }

    // MARK: - Cached
    var cachedTransactions: [Transaction] {
        fileCache.transactions
    }

    func refreshFromCache() {
        try? fileCache.load(from: fileURL)
    }

    // MARK: - Load
    func getTransactions(forAccount accountId: Int, from start: Date, to end: Date) async throws -> [Transaction] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        let queryItems = [
            URLQueryItem(name: "startDate", value: formatter.string(from: start)),
            URLQueryItem(name: "endDate", value: formatter.string(from: end))
        ]

        let path = "transactions/account/\(accountId)/period"

        // Попытка синхронизации бэкапа
        if let backupStore {
            let backups = try await backupStore.getAll()
            for backup in backups {
                do {
                    switch backup.action {
                    case .create:
                        let oldId = backup.transaction.id
                        let newTx = TransactionRequestBody(from: backup.transaction)
                        let created = try await createTransaction(newTx)
                        try? await localStore?.delete(by: oldId)
                        try? await backupStore.delete(by: oldId)
                    case .update:
                        _ = try await updateTransaction(id: backup.transaction.id, with: TransactionRequestBody(from: backup.transaction))
                        try? await backupStore.delete(by: backup.transaction.id)
                    case .delete:
                        try await deleteTransaction(id: backup.transaction.id)
                        try? await backupStore.delete(by: backup.transaction.id)
                    }
                } catch {
                    print("Failed to sync backup transaction \(backup.transaction.id): \(error.localizedDescription)")
                }
            }
        }

        do {
            let txs: [Transaction] = try await client.request(
                path: path,
                method: "GET",
                body: Optional<EmptyRequest>.none,
                queryItems: queryItems
            )
            fileCache.replaceAll(txs)
            try? fileCache.save(to: fileURL)
            try? await localStore?.replaceAll(txs)
            return txs
        } catch {
            let local = try await localStore?.getAll() ?? []
            let backup = try await backupStore?.getAll().map { $0.transaction } ?? []
            let merged = (local + backup).filter {
                $0.account.id == accountId && $0.transactionDate >= start && $0.transactionDate <= end
            }
            return merged
        }
    }

    // MARK: - Create
    func createTransaction(_ tx: TransactionRequestBody) async throws -> Transaction {
        do {
            let response: TransactionResponseBody = try await client.request(
                path: "transactions",
                method: "POST",
                body: tx
            )

            let account = try await BankAccountsService(client: client).getAccount(withId: response.accountId)
            let category = try await CategoriesService(client: client).getCategory(withId: response.categoryId)
            let formatter = ISO8601DateFormatter()

            let transaction = Transaction(
                id: response.id,
                account: account,
                category: category,
                amount: Decimal(string: response.amount) ?? 0,
                transactionDate: formatter.date(from: response.transactionDate) ?? Date(),
                comment: response.comment,
                createdAt: formatter.date(from: response.createdAt) ?? Date(),
                updatedAt: formatter.date(from: response.updatedAt) ?? Date()
            )

            fileCache.add(transaction)
            try? fileCache.save(to: fileURL)
            try? await localStore?.create(transaction)
            try? await backupStore?.delete(by: transaction.id)
            return transaction
        } catch {
            let tempId = Int(Date().timeIntervalSince1970 * -1)
            let dummy = Transaction(
                id: tempId,
                account: .dummy,
                category: .dummy,
                amount: Decimal(string: tx.amount) ?? 0,
                transactionDate: ISO8601DateFormatter().date(from: tx.transactionDate) ?? Date(),
                comment: tx.comment,
                createdAt: Date(),
                updatedAt: Date()
            )
            try? await localStore?.create(dummy)
            try? await backupStore?.save(TransactionBackupModel(id: tempId, action: .create, transaction: dummy))
            throw error
        }
    }

    // MARK: - Update
    func updateTransaction(id: Int, with tx: TransactionRequestBody) async throws -> Transaction {
        do {
            let updated: Transaction = try await client.request(
                path: "transactions/\(id)",
                method: "PUT",
                body: tx
            )

            fileCache.remove(withId: id)
            fileCache.add(updated)
            try? fileCache.save(to: fileURL)
            try? await localStore?.update(updated)
            try? await backupStore?.delete(by: id)
            return updated
        } catch {
            try? await backupStore?.save(TransactionBackupModel(id: id, action: .update, transaction: Transaction(from: tx, id: id)))
            throw error
        }
    }

    // MARK: - Delete
    func deleteTransaction(id: Int) async throws {
        do {
            _ = try await client.request(
                path: "transactions/\(id)",
                method: "DELETE",
                body: EmptyRequest()
            ) as Void

            fileCache.remove(withId: id)
            try? fileCache.save(to: fileURL)
            try? await localStore?.delete(by: id)
            try? await backupStore?.delete(by: id)
        } catch {
            let dummy = Transaction(id: id, account: .dummy, category: .dummy, amount: 0, transactionDate: Date(), comment: nil, createdAt: Date(), updatedAt: Date())
            try? await backupStore?.save(TransactionBackupModel(id: id, action: .delete, transaction: dummy))
            throw error
        }
    }
}
