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

// MARK: - Display Model (Presenter → View)

/// Fully formatted, UI-ready data. Produced by Presenter, consumed by View.
struct WeatherDisplayModel {
    let cityName: String
    let temperature: String
    let conditionText: String
    let feelsLike: String
    let conditionCode: Int
    let isDay: Bool
    let humidity: String
    let windSpeed: String
    let windDirection: String
    let pressure: String
    let visibility: String
    let uvIndex: String
    let gradientTop: String
    let gradientBottom: String

    let hourlyItems: [HourlyDisplayItem]
    let dailyItems: [DailyDisplayItem]

    struct HourlyDisplayItem {
        let time: String
        let temperature: String
        let conditionCode: Int
        let isDay: Bool
        let chanceOfRain: Int
    }

    struct DailyDisplayItem {
        let dayName: String
        let conditionCode: Int
        let tempMax: String
        let tempMin: String
        let chanceOfRain: Int
    }
}
