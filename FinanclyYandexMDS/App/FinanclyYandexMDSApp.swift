import SwiftUI
import SwiftData

@main
struct FinanclyYandexMDSApp: App {
    @AppStorage("accessToken") private var token: String = "GvUPD1yQOe2O25jERIiXhbKU"
    @AppStorage("userId") private var userId: Int = 95

    let container: ModelContainer = {
        let schema = Schema([
            TransactionEntity.self,
            AccountEntity.self,
            CategoryEntity.self,
            TransactionBackupModel.self
        ])

        let config = ModelConfiguration(
            schema: schema,
            url: FileManager.default
                .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("main.store")
        )

        return try! ModelContainer(for: schema, configurations: [config])
    }()

    var body: some Scene {
        WindowGroup {
            let client = NetworkClient(token: token)
            MainTab(
                client: client,
                accountId: userId,
                modelContainer: container
            )
        }
    }
}
