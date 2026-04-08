//
//  WeatherNetworkService.swift
//  PWRS_test
//
//  Infrastructure layer — wraps URLSession behind a protocol.
//

import Foundation

// MARK: - Protocol

protocol WeatherNetworkServiceProtocol: AnyObject {
    func fetchForecast(lat: Double, lon: Double) async -> Result<ForecastWeatherResponse, WeatherServiceError>
}

// MARK: - Implementation

final class WeatherNetworkService: WeatherNetworkServiceProtocol {

    private let apiKey = "fa8b3df74d4042b9aa7135114252304"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchForecast(lat: Double, lon: Double) async -> Result<ForecastWeatherResponse, WeatherServiceError> {
        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(lat),\(lon)&days=3&lang=ru"

        guard let url = URL(string: urlString) else {
            return .failure(.invalidResponse)
        }

        do {
            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return .failure(.invalidResponse)
            }
            let decoded = try JSONDecoder().decode(ForecastWeatherResponse.self, from: data)
            return .success(decoded)
        } catch let error as DecodingError {
            return .failure(.decodingError(error))
        } catch {
            return .failure(.networkError(error))
        }
    }
}
