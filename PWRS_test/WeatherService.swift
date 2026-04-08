//
//  WeatherService.swift
//  PWRS_test
//

import Foundation
import CoreLocation

// MARK: - Weather Service Errors

enum WeatherServiceError: LocalizedError {
    case locationDenied
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .locationDenied:
            return "Доступ к геолокации запрещён. Используется Москва."
        case .networkError(let err):
            return "Ошибка сети: \(err.localizedDescription)"
        case .invalidResponse:
            return "Некорректный ответ от сервера"
        case .decodingError:
            return "Ошибка обработки данных"
        }
    }
}

// MARK: - Weather Service

final class WeatherService: NSObject {

    private let apiKey = "fa8b3df74d4042b9aa7135114252304"
    private let moscowLat = 55.7558
    private let moscowLon = 37.6176

    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Never>?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    // MARK: - Public API

    func fetchWeather() async -> Result<WeatherViewModel, WeatherServiceError> {
        let coordinate = await resolveCoordinate()
        return await fetchForecast(lat: coordinate.latitude, lon: coordinate.longitude)
    }

    // MARK: - Location

    private func resolveCoordinate() async -> CLLocationCoordinate2D {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            // Request permission and wait for callback
            let coordinate = await withCheckedContinuation { (continuation: CheckedContinuation<CLLocationCoordinate2D, Never>) in
                self.locationContinuation = continuation
                self.locationManager.requestWhenInUseAuthorization()
            }
            return coordinate
        case .authorizedWhenInUse, .authorizedAlways:
            return await getCurrentLocation()
        default:
            return CLLocationCoordinate2D(latitude: moscowLat, longitude: moscowLon)
        }
    }

    private func getCurrentLocation() async -> CLLocationCoordinate2D {
        return await withCheckedContinuation { (continuation: CheckedContinuation<CLLocationCoordinate2D, Never>) in
            self.locationContinuation = continuation
            self.locationManager.requestLocation()
        }
    }

    // MARK: - Network

    private func fetchForecast(lat: Double, lon: Double) async -> Result<WeatherViewModel, WeatherServiceError> {
        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(lat),\(lon)&days=3&lang=ru"

        guard let url = URL(string: urlString) else {
            return .failure(.invalidResponse)
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return .failure(.invalidResponse)
            }

            let decoded = try JSONDecoder().decode(ForecastWeatherResponse.self, from: data)
            let viewModel = buildViewModel(from: decoded)
            return .success(viewModel)

        } catch let error as DecodingError {
            return .failure(.decodingError(error))
        } catch {
            return .failure(.networkError(error))
        }
    }

    // MARK: - ViewModel Builder

    private func buildViewModel(from response: ForecastWeatherResponse) -> WeatherViewModel {
        let current = response.current
        let location = response.location
        let isDay = current.isDay == 1

        // Build hourly items: remaining hours of today + all hours of tomorrow
        var hourlyItems: [WeatherViewModel.HourlyItem] = []

        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)

        let todayForecast = response.forecast.forecastday.first
        let tomorrowForecast = response.forecast.forecastday.count > 1 ? response.forecast.forecastday[1] : nil

        // Today's remaining hours (current hour onwards)
        if let today = todayForecast {
            for hour in today.hour {
                let hourVal = hourFromTimeString(hour.time)
                if hourVal >= currentHour {
                    let label = hourVal == currentHour ? "Сейчас" : String(format: "%02d:00", hourVal)
                    hourlyItems.append(WeatherViewModel.HourlyItem(
                        time: label,
                        temperature: "\(Int(hour.tempC.rounded()))°",
                        conditionCode: hour.condition.code,
                        isDay: hour.isDay == 1,
                        chanceOfRain: hour.chanceOfRain
                    ))
                }
            }
        }

        // Tomorrow's all hours
        if let tomorrow = tomorrowForecast {
            for hour in tomorrow.hour {
                let hourVal = hourFromTimeString(hour.time)
                let label = String(format: "%02d:00", hourVal)
                hourlyItems.append(WeatherViewModel.HourlyItem(
                    time: label,
                    temperature: "\(Int(hour.tempC.rounded()))°",
                    conditionCode: hour.condition.code,
                    isDay: hour.isDay == 1,
                    chanceOfRain: hour.chanceOfRain
                ))
            }
        }

        // Build daily items (3 days)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ru_RU")

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "d MMM"
        displayFormatter.locale = Locale(identifier: "ru_RU")

        let dayNameFormatter = DateFormatter()
        dayNameFormatter.dateFormat = "EEEE"
        dayNameFormatter.locale = Locale(identifier: "ru_RU")

        var dailyItems: [WeatherViewModel.DailyItem] = []
        for (index, day) in response.forecast.forecastday.enumerated() {
            let dayName: String
            if let date = dateFormatter.date(from: day.date) {
                if index == 0 {
                    dayName = "Сегодня"
                } else if index == 1 {
                    dayName = "Завтра"
                } else {
                    dayName = dayNameFormatter.string(from: date).capitalized
                }
            } else {
                dayName = day.date
            }

            let dateDisplay: String
            if let date = dateFormatter.date(from: day.date) {
                dateDisplay = displayFormatter.string(from: date)
            } else {
                dateDisplay = day.date
            }

            dailyItems.append(WeatherViewModel.DailyItem(
                dayName: dayName,
                dateString: dateDisplay,
                conditionCode: day.day.condition.code,
                tempMax: "\(Int(day.day.maxtempC.rounded()))°",
                tempMin: "\(Int(day.day.mintempC.rounded()))°",
                chanceOfRain: day.day.dailyChanceOfRain,
                sunrise: day.astro.sunrise,
                sunset: day.astro.sunset
            ))
        }

        return WeatherViewModel(
            cityName: location.name,
            region: location.region,
            temperature: "\(Int(current.tempC.rounded()))°",
            feelsLike: "Ощущается как \(Int(current.feelslikeC.rounded()))°",
            conditionText: current.condition.text,
            conditionCode: current.condition.code,
            isDay: isDay,
            humidity: "\(current.humidity)%",
            windSpeed: "\(Int(current.windKph.rounded())) км/ч",
            windDirection: current.windDir,
            pressure: "\(Int(current.pressureMb.rounded())) мбар",
            visibility: "\(Int(current.visKm.rounded())) км",
            uvIndex: String(format: "%.0f", current.uv),
            hourlyItems: hourlyItems,
            dailyItems: dailyItems
        )
    }

    private func hourFromTimeString(_ timeString: String) -> Int {
        // Format: "2024-01-01 14:00"
        let parts = timeString.split(separator: " ")
        guard parts.count == 2 else { return 0 }
        let timeParts = parts[1].split(separator: ":")
        guard let hour = Int(timeParts[0]) else { return 0 }
        return hour
    }
}

// MARK: - CLLocationManagerDelegate

extension WeatherService: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationContinuation?.resume(returning: location.coordinate)
            locationContinuation = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(returning: CLLocationCoordinate2D(latitude: moscowLat, longitude: moscowLon))
        locationContinuation = nil
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // Permission just granted — request actual location
            if locationContinuation != nil {
                manager.requestLocation()
            }
        case .denied, .restricted:
            locationContinuation?.resume(returning: CLLocationCoordinate2D(latitude: moscowLat, longitude: moscowLon))
            locationContinuation = nil
        default:
            break
        }
    }
}
