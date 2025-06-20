import Foundation

final class TransactionsFileCache {

    // MARK: - Enum Exceptions
    enum CacheError: Error {
        case invalidJSON
        case invalidStructure
    }

    // MARK: - Date Formatter
    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        return f
    }()

    // MARK: - Storage
    private(set) var transactions: [Transaction] = []

    
    // MARK: - CRUD
    func add(_ tx: Transaction) {
        guard !transactions.contains(where: { $0.id == tx.id }) else { return }
        transactions.append(tx)
    }

    // Remove by ID
    func remove(withId id: Int) {
        transactions.removeAll { $0.id == id }
    }

    // MARK: - Persistence
    // Save as JSON file
    func save(to fileURL: URL) throws {
        let objs = transactions.map { $0.jsonObject }
        guard JSONSerialization.isValidJSONObject(objs) else {
            throw CacheError.invalidJSON
        }
        let data = try JSONSerialization.data(withJSONObject: objs, options: [.prettyPrinted])
        try data.write(to: fileURL, options: [.atomic])
    }

    /// Load from JSON file
    func load(from fileURL: URL) throws {
        let data = try Data(contentsOf: fileURL)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let arr = json as? [Any] else {
            throw CacheError.invalidStructure
        }
        var loaded: [Transaction] = []
        for obj in arr {
            if let tx = Transaction.parse(jsonObject: obj) {
                loaded.append(tx)
            } else {
                print("Failed to parse transaction: \(obj)")
            }
        }
        
        // Delete clone by id
        let uniq = Dictionary(grouping: loaded, by: \.id).compactMapValues { $0.first }
        transactions = Array(uniq.values)
    }

    // MARK: - Helpers
    // Default file URL in Documents
    static func defaultFileURL(fileName: String) -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("\(fileName).json")
    }
}
