import SwiftUI
import UIKit

/// UIScrollView (na kterém SwiftUI `ScrollView` staví) má defaultně zapnuté
/// `delaysContentTouches`, které chvíli váhá, jestli jde o tap na tlačítko
/// uvnitř scrollu, nebo o začátek scroll/swipe gesta. Na iPadu (kde navíc
/// hraje roli i gesto pro swipe zpět) se to projevuje jako tlačítka, která
/// je potřeba stisknout víckrát, než zareagují. Tenhle modifier najde
/// nejbližší nadřazený `UIScrollView` a delay vypne, aby tapy reagovaly
/// okamžitě. Scrollování samotné to neovlivňuje.
private struct ScrollViewTapDelayFix: UIViewRepresentable {

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear

        DispatchQueue.main.async {
            var current: UIView? = view.superview
            while let candidate = current {
                if let scrollView = candidate as? UIScrollView {
                    scrollView.delaysContentTouches = false
                    break
                }
                current = candidate.superview
            }
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

extension View {
    /// Vypne `delaysContentTouches` na nejbližším nadřazeném `UIScrollView`,
    /// aby tlačítka uvnitř `ScrollView` reagovala na první tap.
    func fixScrollViewTapDelay() -> some View {
        background(ScrollViewTapDelayFix())
    }
}
