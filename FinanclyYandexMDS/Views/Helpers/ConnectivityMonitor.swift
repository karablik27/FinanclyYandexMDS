import Network
import SwiftUI

@MainActor
final class ConnectivityMonitor: ObservableObject {
    @Published var isOffline: Bool = false

    private var monitor: NWPathMonitor?
    private let queue = DispatchQueue(label: "ConnectivityMonitor")

    init() {
        monitor = NWPathMonitor()
        monitor?.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isOffline = (path.status != .satisfied)
            }
        }
        monitor?.start(queue: queue)
    }

    deinit {
        monitor?.cancel()
    }
}
