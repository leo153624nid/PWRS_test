//
//  WeatherProtocols.swift
//  PWRS_test
//
//  VIPER contracts for the Weather module.
//  All inter-layer communication goes through these protocols.
//

import UIKit

// MARK: - View ← Presenter

/// The passive View. Presenter calls these methods to update the UI.
@MainActor
protocol WeatherViewProtocol: AnyObject {
    func showLoading()
    func showWeather(_ displayModel: WeatherDisplayModel)
    func showError(_ message: String)
}

// MARK: - Presenter ← View (user events)

/// View delegates user actions to Presenter via this protocol.
protocol WeatherPresenterProtocol: AnyObject {
    func viewDidLoad()
    func retryTapped()
}

// MARK: - Interactor ← Presenter

/// Presenter triggers data fetching via Interactor.
protocol WeatherInteractorProtocol: AnyObject {
    func fetchWeather() async
}

// MARK: - Presenter ← Interactor (output)

/// Interactor calls back Presenter with results.
protocol WeatherInteractorOutputProtocol: AnyObject {
    func didFetchWeather(_ data: WeatherData)
    func didFailFetching(_ error: WeatherServiceError)
}

// MARK: - Router

/// Responsible for module assembly and navigation.
protocol WeatherRouterProtocol: AnyObject {
    static func buildModule() -> UIViewController
}
