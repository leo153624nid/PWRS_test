//
//  WeatherIconMapper.swift
//  PWRS_test
//
//  Helpers layer — maps WeatherAPI condition codes to SF Symbols and gradient colors.
//

import Foundation

enum WeatherIconMapper {

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

    static func gradientColors(for code: Int, isDay: Bool) -> (top: String, bottom: String) {
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
