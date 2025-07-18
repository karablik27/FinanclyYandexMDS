import SwiftUI

struct MainTab: View {
    // MARK: - Dependencies
    let client: NetworkClient
    let accountId: Int

    // MARK: - Init
    init(client: NetworkClient, accountId: Int) {
        self.client = client
        self.accountId = accountId

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    // MARK: - Body
    var body: some View {
        TabView {
            // MARK: - Expenses Tab
            TransactionsListView(direction: .outcome, client: client, accountId: accountId)
                .tabItem {
                    Label {
                        Text("Расходы")
                    } icon: {
                        Image("расходы")
                            .renderingMode(.template)
                    }
                }

            // MARK: - Income Tab
            TransactionsListView(direction: .income, client: client, accountId: accountId)
                .tabItem {
                    Label {
                        Text("Доходы")
                    } icon: {
                        Image("доходы")
                            .renderingMode(.template)
                    }
                }

            // MARK: - Account Tab
            BankAccountView(client: client)
                .tabItem {
                    Label {
                        Text("Счет")
                    } icon: {
                        Image("счет")
                            .renderingMode(.template)
                    }
                }

            // MARK: - Categories Tab
            CategoriesView(client: client)
                .tabItem {
                    Label {
                        Text("Статьи")
                    } icon: {
                        Image("статьи")
                            .renderingMode(.template)
                    }
                }

            // MARK: - Settings Tab
            Text("Настройки")
                .tabItem {
                    Label {
                        Text("Настройки")
                    } icon: {
                        Image("настройки")
                            .renderingMode(.template)
                    }
                }
        }
        .accentColor(Color("AccentColor"))
    }
}
