//
//  WeatherServiceError.swift
//  PWRS_test
//
//  Shared error type used across Services and Interactor layers.
//

import Foundation

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
