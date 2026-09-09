import SwiftUI
import UIKit

/// `.toolbarVisibility(.hidden, for: .navigationBar)` / `.navigationBarHidden(true)`
/// schovají navigační lištu jen vizuálně. Na iPadu ale skutečná UIKit vrstva
/// `UINavigationBar` zůstává přítomná a interaktivní, takže si dál drží
/// neviditelnou hit-test oblast nahoře obrazovky a "krade" doteky určené
/// prvkům pod ní (viz např. https://medium.com/better-programming/swiftui-navigationbar-is-not-really-hidden-as-you-expect-785ff0425c86).
///
/// Tenhle modifier najde skutečný `UINavigationController` dané hierarchie
/// a zavolá na něm `setNavigationBarHidden(true, animated: false)` přímo,
/// čímž lištu opravdu odstraní i s její hit-test oblastí.
private struct NavigationBarTrueHider: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        vc.view.isUserInteractionEnabled = false
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            guard let navigationController = uiViewController.navigationController else { return }
            if !navigationController.isNavigationBarHidden {
                navigationController.setNavigationBarHidden(true, animated: false)
            }
        }
    }
}

extension View {
    /// Skutečně (na úrovni UIKit) skryje navigační lištu, včetně její
    /// hit-test oblasti — na rozdíl od `.toolbarVisibility`/`.navigationBarHidden`,
    /// které na iPadu nechávají lištu interaktivní i když je neviditelná.
    func trulyHideNavigationBar() -> some View {
        background(NavigationBarTrueHider())
    }
}
