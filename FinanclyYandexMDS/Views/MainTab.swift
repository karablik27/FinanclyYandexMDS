import SwiftUI

struct MainTab: View {
    
    // MARK: - Init
    init() {
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
            TransactionsListView(direction: .outcome)
                .tabItem {
                    Label {
                        Text("Расходы")
                    } icon: {
                        Image("расходы")
                            .renderingMode(.template)
                    }
                }

            // MARK: - Income Tab
            TransactionsListView(direction: .income)
                .tabItem {
                    Label {
                        Text("Доходы")
                    } icon: {
                        Image("доходы")
                            .renderingMode(.template)
                    }
                }

            // MARK: - Account Tab
            Text("Счет")
                .tabItem {
                    Label {
                        Text("Счет")
                    } icon: {
                        Image("счет")
                            .renderingMode(.template)
                    }
                }

            // MARK: - Categories Tab
            Text("Статьи")
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
