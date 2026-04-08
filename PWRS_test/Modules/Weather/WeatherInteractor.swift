//
//  WeatherInteractor.swift
//  PWRS_test
//
//  Use Cases layer — business logic only.
//  Knows nothing about UIKit or display formatting.
//

import Foundation

final class WeatherInteractor: WeatherInteractorProtocol {

    // MARK: - Dependencies (injected via init)

    private let locationService: LocationServiceProtocol
    private let networkService: WeatherNetworkServiceProtocol

    /// Weak reference to Presenter (output channel)
    weak var output: WeatherInteractorOutputProtocol?

    // MARK: - Init

    init(
        locationService: LocationServiceProtocol,
        networkService: WeatherNetworkServiceProtocol
    ) {
        self.locationService = locationService
        self.networkService = networkService
    }

    // MARK: - WeatherInteractorProtocol

    func fetchWeather() async {
        // 1. Resolve coordinates (handles permission + fallback internally)
        let coordinate = await locationService.resolveCoordinate()

        // 2. Fetch forecast from API
        let result = await networkService.fetchForecast(lat: coordinate.lat, lon: coordinate.lon)

        // 3. Route result to Presenter output
        switch result {
        case .success(let response):
            let domainData = mapToDomain(response: response)
            output?.didFetchWeather(domainData)
        case .failure(let error):
            output?.didFailFetching(error)
        }
    }

    // MARK: - Domain Mapping

    /// Maps raw API response to domain WeatherData.
    /// Pure data transformation — no strings, no formatting.
    private func mapToDomain(response: ForecastWeatherResponse) -> WeatherData {
        let current = response.current
        let isDay = current.isDay == 1

        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: Date())

        // Hourly: remaining hours today + all hours tomorrow
        var hourlyItems: [WeatherData.HourlyData] = []

        if let today = response.forecast.forecastday.first {
            for hour in today.hour {
                let h = hourFromTimeString(hour.time)
                guard h >= currentHour else { continue }
                hourlyItems.append(WeatherData.HourlyData(
                    hour: h,
                    isCurrentHour: h == currentHour,
                    tempC: hour.tempC,
                    conditionCode: hour.condition.code,
                    isDay: hour.isDay == 1,
                    chanceOfRain: hour.chanceOfRain
                ))
            }
        }

        if response.forecast.forecastday.count > 1 {
            let tomorrow = response.forecast.forecastday[1]
            for hour in tomorrow.hour {
                hourlyItems.append(WeatherData.HourlyData(
                    hour: hourFromTimeString(hour.time),
                    isCurrentHour: false,
                    tempC: hour.tempC,
                    conditionCode: hour.condition.code,
                    isDay: hour.isDay == 1,
                    chanceOfRain: hour.chanceOfRain
                ))
            }
        }

        // Daily: all 3 days
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let dailyItems: [WeatherData.DailyData] = response.forecast.forecastday
            .enumerated()
            .map { index, day in
                WeatherData.DailyData(
                    date: dateFormatter.date(from: day.date),
                    dateString: day.date,
                    dayIndex: index,
                    conditionCode: day.day.condition.code,
                    maxtempC: day.day.maxtempC,
                    mintempC: day.day.mintempC,
                    chanceOfRain: day.day.dailyChanceOfRain,
                    sunrise: day.astro.sunrise,
                    sunset: day.astro.sunset
                )
            }

        return WeatherData(
            cityName: response.location.name,
            region: response.location.region,
            tempC: current.tempC,
            feelsLikeC: current.feelslikeC,
            conditionText: current.condition.text,
            conditionCode: current.condition.code,
            isDay: isDay,
            humidity: current.humidity,
            windKph: current.windKph,
            windDir: current.windDir,
            pressureMb: current.pressureMb,
            visKm: current.visKm,
            uv: current.uv,
            hourlyItems: hourlyItems,
            dailyItems: dailyItems
        )
    }

    private func hourFromTimeString(_ timeString: String) -> Int {
        let parts = timeString.split(separator: " ")
        guard parts.count == 2 else { return 0 }
        let timeParts = parts[1].split(separator: ":")
        return Int(timeParts[0]) ?? 0
    }
}
