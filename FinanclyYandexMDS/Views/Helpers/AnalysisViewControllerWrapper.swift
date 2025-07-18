import SwiftUI

struct AnalysisViewControllerWrapper: UIViewControllerRepresentable {
    let service: TransactionsService
    let accountId: Int
    let direction: Direction

    func makeUIViewController(context: Context) -> UIViewController {
        return AnalysisViewController(service: service, accountId: accountId, direction: direction)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
