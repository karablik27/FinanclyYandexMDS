//
//  RootView.swift
//  FinanclyYandexMDS
//
//  Created by Верховный Маг on 26.07.2025.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @State private var isAnimationCompleted = false

    let client: NetworkClient
    let accountId: Int
    let modelContainer: ModelContainer

    var body: some View {
        Group {
            if isAnimationCompleted {
                MainTab(client: client, accountId: accountId, modelContainer: modelContainer)
            } else {
                LaunchAnimationView {
                    withAnimation {
                        isAnimationCompleted = true
                    }
                }
                .ignoresSafeArea()
            }
        }
    }
}
