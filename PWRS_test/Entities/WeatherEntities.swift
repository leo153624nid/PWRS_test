//
//  WeatherEntities.swift
//  PWRS_test
//
//  Entities layer — pure Swift data models, no UIKit, no networking.
//

import Foundation

// MARK: - API Response Models (Decodable)

struct ForecastWeatherResponse: Decodable {
    let location: APILocation
    let current: APICurrentWeather
    let forecast: APIForecast
}

struct APILocation: Decodable {
    let name: String
    let region: String
    let country: String
    let localtime: String
}

struct APICurrentWeather: Decodable {
    let tempC: Double
    let feelslikeC: Double
    let humidity: Int
    let windKph: Double
    let windDir: String
    let pressureMb: Double
    let visKm: Double
    let uv: Double
    let isDay: Int
    let condition: APIWeatherCondition

    enum CodingKeys: String, CodingKey {
        case tempC = "temp_c"
        case feelslikeC = "feelslike_c"
        case humidity
        case windKph = "wind_kph"
        case windDir = "wind_dir"
        case pressureMb = "pressure_mb"
        case visKm = "vis_km"
        case uv
        case isDay = "is_day"
        case condition
    }
}

struct APIWeatherCondition: Decodable {
    let text: String
    let icon: String
    let code: Int
}

struct APIForecast: Decodable {
    let forecastday: [APIForecastDay]
}

struct APIForecastDay: Decodable {
    let date: String
    let day: APIDaySummary
    let astro: APIAstro
    let hour: [APIHourWeather]
}

struct APIDaySummary: Decodable {
    let maxtempC: Double
    let mintempC: Double
    let avgtempC: Double
    let maxwindKph: Double
    let avghumidity: Double
    let dailyChanceOfRain: Int
    let condition: APIWeatherCondition

    enum CodingKeys: String, CodingKey {
        case maxtempC = "maxtemp_c"
        case mintempC = "mintemp_c"
        case avgtempC = "avgtemp_c"
        case maxwindKph = "maxwind_kph"
        case avghumidity
        case dailyChanceOfRain = "daily_chance_of_rain"
        case condition
    }
}

struct APIAstro: Decodable {
    let sunrise: String
    let sunset: String
}

struct APIHourWeather: Decodable {
    let timeEpoch: Int
    let time: String
    let tempC: Double
    let chanceOfRain: Int
    let condition: APIWeatherCondition
    let isDay: Int

    enum CodingKeys: String, CodingKey {
        case timeEpoch = "time_epoch"
        case time
        case tempC = "temp_c"
        case chanceOfRain = "chance_of_rain"
        case condition
        case isDay = "is_day"
    }
}

// MARK: - Domain Model

/// Domain-level weather data passed from Interactor to Presenter.
/// Contains raw numeric values — no formatted strings, no UIKit.
struct WeatherData {
    let cityName: String
    let region: String
    let tempC: Double
    let feelsLikeC: Double
    let conditionText: String
    let conditionCode: Int
    let isDay: Bool
    let humidity: Int
    let windKph: Double
    let windDir: String
    let pressureMb: Double
    let visKm: Double
    let uv: Double

    let hourlyItems: [HourlyData]
    let dailyItems: [DailyData]

    struct HourlyData {
        let hour: Int           // 0–23
        let isCurrentHour: Bool
        let tempC: Double
        let conditionCode: Int
        let isDay: Bool
        let chanceOfRain: Int
    }

    struct DailyData {
        let date: Date?
        let dateString: String  // raw "yyyy-MM-dd"
        let dayIndex: Int       // 0 = today, 1 = tomorrow, 2+ = other
        let conditionCode: Int
        let maxtempC: Double
        let mintempC: Double
        let chanceOfRain: Int
        let sunrise: String
        let sunset: String
    }
}
