//
//  WeatherDisplayModel.swift
//  PWRS_test
//
//  Fully formatted, UI-ready data. Produced by Presenter, consumed by View.
//

// MARK: - Display Model (Presenter → View)

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
