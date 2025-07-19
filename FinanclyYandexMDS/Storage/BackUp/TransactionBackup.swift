enum BackupAction: String, Codable {
    case create
    case update
    case delete
}

struct TransactionBackup: Identifiable, Codable {
    let id: Int
    let action: BackupAction
    let transaction: Transaction
}
