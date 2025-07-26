import SwiftUI
import Lottie

struct LaunchAnimationView: UIViewRepresentable {
    let onComplete: () -> Void

    func makeUIView(context: Context) -> some UIView {
        let animationView = LottieAnimationView(name: "pig")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.play { finished in
            if finished {
                onComplete()
            }
        }
        return animationView
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
