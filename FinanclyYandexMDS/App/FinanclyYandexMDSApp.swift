import SwiftUI

@main
struct FinanclyYandexMDSApp: App {
    @AppStorage("accessToken") private var token: String = "GvUPD1yQOe2O25jERIiXhbKU"
    @AppStorage("userId") private var userId: Int = 95

    var body: some Scene {
        WindowGroup {
            let client = NetworkClient(token: token)
            MainTab(client: client, accountId: userId)
        }
    }
}
