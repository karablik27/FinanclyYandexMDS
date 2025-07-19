protocol BankAccountsLocalStore {
    func saveAll(_ accounts: [BankAccount]) async throws
    func getAll() async throws -> [BankAccount]
}
