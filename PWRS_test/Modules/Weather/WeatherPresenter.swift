//
//  WeatherPresenter.swift
//  PWRS_test
//
//  Interface Adapters layer — mediates between Interactor and View.
//  Receives domain WeatherData, formats it into WeatherDisplayModel, updates View.
//

import Foundation

final class WeatherPresenter: WeatherPresenterProtocol {

    // MARK: - References

    weak var view: WeatherViewProtocol?
    var interactor: WeatherInteractorProtocol?
    var router: WeatherRouterProtocol?

    // MARK: - WeatherPresenterProtocol

    func viewDidLoad() {
        view?.showLoading()
        Task {
            await interactor?.fetchWeather()
        }
    }

    func retryTapped() {
        view?.showLoading()
        Task {
            await interactor?.fetchWeather()
        }
    }

    func infoTapped() {
        guard let vc = view as? UIViewController else { return }
        router?.showInfo(from: vc)
    }
}

// MARK: - WeatherInteractorOutputProtocol

extension WeatherPresenter: WeatherInteractorOutputProtocol {

    func didFetchWeather(_ data: WeatherData) {
        let displayModel = buildDisplayModel(from: data)
        Task { @MainActor in
            view?.showWeather(displayModel)
        }
    }

    func didFailFetching(_ error: WeatherServiceError) {
        let message = error.errorDescription ?? "Неизвестная ошибка"
        Task { @MainActor in
            view?.showError(message)
        }
    }
}

// MARK: - Display Model Builder

private extension WeatherPresenter {

    func buildDisplayModel(from data: WeatherData) -> WeatherDisplayModel {
        let gradient = WeatherIconMapper.gradientColors(for: data.conditionCode, isDay: data.isDay)

        let hourlyItems = data.hourlyItems.map { item in
            WeatherDisplayModel.HourlyDisplayItem(
                time: item.isCurrentHour ? "Сейчас" : String(format: "%02d:00", item.hour),
                temperature: "\(Int(item.tempC.rounded()))°",
                conditionCode: item.conditionCode,
                isDay: item.isDay,
                chanceOfRain: item.chanceOfRain
            )
        }

        let dayNameFormatter = DateFormatter()
        dayNameFormatter.dateFormat = "EEEE"
        dayNameFormatter.locale = Locale(identifier: "ru_RU")

        let dailyItems = data.dailyItems.map { item -> WeatherDisplayModel.DailyDisplayItem in
            let dayName: String
            switch item.dayIndex {
            case 0: dayName = "Сегодня"
            case 1: dayName = "Завтра"
            default:
                if let date = item.date {
                    dayName = dayNameFormatter.string(from: date).capitalized
                } else {
                    dayName = item.dateString
                }
            }

            return WeatherDisplayModel.DailyDisplayItem(
                dayName: dayName,
                conditionCode: item.conditionCode,
                tempMax: "\(Int(item.maxtempC.rounded()))°",
                tempMin: "\(Int(item.mintempC.rounded()))°",
                chanceOfRain: item.chanceOfRain
            )
        }

        return WeatherDisplayModel(
            cityName: data.cityName,
            temperature: "\(Int(data.tempC.rounded()))°",
            conditionText: data.conditionText,
            feelsLike: "Ощущается как \(Int(data.feelsLikeC.rounded()))°",
            conditionCode: data.conditionCode,
            isDay: data.isDay,
            humidity: "\(data.humidity)%",
            windSpeed: "\(Int(data.windKph.rounded())) км/ч",
            windDirection: data.windDir,
            pressure: "\(Int(data.pressureMb.rounded())) мбар",
            visibility: "\(Int(data.visKm.rounded())) км",
            uvIndex: String(format: "%.0f", data.uv),
            gradientTop: gradient.top,
            gradientBottom: gradient.bottom,
            hourlyItems: hourlyItems,
            dailyItems: dailyItems
        )
    }
}
