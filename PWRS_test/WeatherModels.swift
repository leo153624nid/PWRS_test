//
//  WeatherModels.swift
//  PWRS_test
//

import Foundation

// MARK: - Current Weather Response

struct CurrentWeatherResponse: Decodable {
    let location: Location
    let current: CurrentWeather
}

// MARK: - Forecast Response

struct ForecastWeatherResponse: Decodable {
    let location: Location
    let current: CurrentWeather
    let forecast: Forecast
}

// MARK: - Location

struct Location: Decodable {
    let name: String
    let region: String
    let country: String
    let localtime: String
}

// MARK: - Current Weather

struct CurrentWeather: Decodable {
    let tempC: Double
    let feelslikeC: Double
    let humidity: Int
    let windKph: Double
    let windDir: String
    let pressureMb: Double
    let visKm: Double
    let uv: Double
    let isDay: Int
    let condition: WeatherCondition

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

// MARK: - Weather Condition

struct WeatherCondition: Decodable {
    let text: String
    let icon: String
    let code: Int
}

// MARK: - Forecast

struct Forecast: Decodable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Decodable {
    let date: String
    let day: DaySummary
    let astro: Astro
    let hour: [HourWeather]
}

struct DaySummary: Decodable {
    let maxtempC: Double
    let mintempC: Double
    let avgtempC: Double
    let maxwindKph: Double
    let avghumidity: Double
    let dailyChanceOfRain: Int
    let condition: WeatherCondition

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

struct Astro: Decodable {
    let sunrise: String
    let sunset: String
}

struct HourWeather: Decodable {
    let timeEpoch: Int
    let time: String
    let tempC: Double
    let chanceOfRain: Int
    let condition: WeatherCondition
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

// MARK: - View Models

struct WeatherViewModel {
    let cityName: String
    let region: String
    let temperature: String
    let feelsLike: String
    let conditionText: String
    let conditionCode: Int
    let isDay: Bool
    let humidity: String
    let windSpeed: String
    let windDirection: String
    let pressure: String
    let visibility: String
    let uvIndex: String

    let hourlyItems: [HourlyItem]
    let dailyItems: [DailyItem]

    struct HourlyItem {
        let time: String
        let temperature: String
        let conditionCode: Int
        let isDay: Bool
        let chanceOfRain: Int
    }

    struct DailyItem {
        let dayName: String
        let dateString: String
        let conditionCode: Int
        let tempMax: String
        let tempMin: String
        let chanceOfRain: Int
        let sunrise: String
        let sunset: String
    }
}

// MARK: - Weather Icon Mapping

enum WeatherIconMapper {
    /// Maps WeatherAPI condition code + isDay to SF Symbol name
    static func sfSymbol(for code: Int, isDay: Bool) -> String {
        switch code {
        case 1000:
            return isDay ? "sun.max.fill" : "moon.stars.fill"
        case 1003:
            return isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case 1006:
            return "cloud.fill"
        case 1009:
            return "smoke.fill"
        case 1030:
            return "cloud.fog.fill"
        case 1063, 1150, 1153, 1168, 1171, 1180, 1183, 1186, 1189, 1192, 1195, 1198, 1201:
            return "cloud.rain.fill"
        case 1066, 1114, 1117, 1210, 1213, 1216, 1219, 1222, 1225, 1255, 1258:
            return "cloud.snow.fill"
        case 1069, 1072, 1204, 1207, 1237, 1249, 1252:
            return "cloud.sleet.fill"
        case 1087, 1273, 1276, 1279, 1282:
            return "cloud.bolt.rain.fill"
        case 1135, 1147:
            return "cloud.fog.fill"
        default:
            return isDay ? "sun.max.fill" : "moon.fill"
        }
    }

    static func backgroundColor(for code: Int, isDay: Bool) -> (top: String, bottom: String) {
        if !isDay {
            return (top: "#1A237E", bottom: "#283593")
        }
        switch code {
        case 1000:
            return (top: "#2196F3", bottom: "#64B5F6")
        case 1003:
            return (top: "#1976D2", bottom: "#42A5F5")
        case 1006, 1009:
            return (top: "#546E7A", bottom: "#78909C")
        case 1030, 1135, 1147:
            return (top: "#607D8B", bottom: "#90A4AE")
        case 1063, 1150...1201:
            return (top: "#1565C0", bottom: "#42A5F5")
        case 1066, 1114, 1117, 1210...1258:
            return (top: "#4FC3F7", bottom: "#B3E5FC")
        case 1087, 1273...1282:
            return (top: "#37474F", bottom: "#546E7A")
        default:
            return (top: "#2196F3", bottom: "#64B5F6")
        }
    }
}
