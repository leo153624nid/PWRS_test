//
//  WeatherRouter.swift
//  PWRS_test
//
//  Interface Adapters layer — module assembly (Composition Root).
//  The only place where all VIPER components are instantiated and wired together.
//

import UIKit

final class WeatherRouter: WeatherRouterProtocol {

    /// Builds and returns a fully configured Weather module.
    static func buildModule() -> UIViewController {
        // 1. Create infrastructure services
        let locationService = LocationService()
        let networkService = WeatherNetworkService()

        // 2. Create VIPER components
        let view = WeatherViewController()
        let presenter = WeatherPresenter()
        let interactor = WeatherInteractor(
            locationService: locationService,
            networkService: networkService
        )
        let router = WeatherRouter()

        // 3. Wire dependencies
        view.presenter = presenter

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router

        interactor.output = presenter

        return view
    }

    func showInfo(from viewController: UIViewController) {
        let infoModule = InfoRouter.buildModule()
        viewController.present(infoModule, animated: true)
    }
}
