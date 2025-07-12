import SwiftUI

struct AnalysisViewControllerWrapper: UIViewControllerRepresentable {
    let direction: Direction

    func makeUIViewController(context: Context) -> UIViewController {
        return AnalysisViewController(direction: direction)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
