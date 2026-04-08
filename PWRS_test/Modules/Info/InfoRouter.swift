//
//  InfoRouter.swift
//  PWRS_test
//
//  VIPER Router for the Info module — assembly and navigation.
//

import UIKit

final class InfoRouter: InfoRouterProtocol {

    weak var viewController: UIViewController?

    static func buildModule() -> UIViewController {
        let view = InfoViewController()
        let presenter = InfoPresenter()
        let router = InfoRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        router.viewController = view

        let nav = UINavigationController(rootViewController: view)
        nav.modalPresentationStyle = .formSheet
        return nav
    }

    func dismiss() {
        viewController?.dismiss(animated: true)
    }
}
