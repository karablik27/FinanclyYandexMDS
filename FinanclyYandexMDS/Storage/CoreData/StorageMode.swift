import Foundation

enum StorageMode: String {
    case swiftdata
    case coredata

    static var current: StorageMode {
        let raw = UserDefaults.standard.string(forKey: "storage_method") ?? "swiftdata"
        return StorageMode(rawValue: raw) ?? .swiftdata
    }

    static func set(_ mode: StorageMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: "storage_method")
    }
}
