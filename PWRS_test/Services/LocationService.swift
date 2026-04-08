//
//  LocationService.swift
//  PWRS_test
//
//  Infrastructure layer — wraps CLLocationManager behind a protocol.
//

import Foundation
import CoreLocation

// MARK: - Protocol

protocol LocationServiceProtocol: AnyObject {
    /// Returns user coordinates, or Moscow fallback if permission denied / error.
    func resolveCoordinate() async -> (lat: Double, lon: Double)
}

// MARK: - Implementation

final class LocationService: NSObject, LocationServiceProtocol {

    private let moscowLat = 55.7558
    private let moscowLon = 37.6176

    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<(lat: Double, lon: Double), Never>?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    func resolveCoordinate() async -> (lat: Double, lon: Double) {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                self.locationContinuation = continuation
                self.locationManager.requestWhenInUseAuthorization()
            }
        case .authorizedWhenInUse, .authorizedAlways:
            return await requestCurrentLocation()
        default:
            return (moscowLat, moscowLon)
        }
    }

    private func requestCurrentLocation() async -> (lat: Double, lon: Double) {
        return await withCheckedContinuation { continuation in
            self.locationContinuation = continuation
            self.locationManager.requestLocation()
        }
    }

    private var moscowCoordinate: (lat: Double, lon: Double) {
        (moscowLat, moscowLon)
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        locationContinuation?.resume(returning: (location.coordinate.latitude, location.coordinate.longitude))
        locationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(returning: moscowCoordinate)
        locationContinuation = nil
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if locationContinuation != nil {
                manager.requestLocation()
            }
        case .denied, .restricted:
            locationContinuation?.resume(returning: moscowCoordinate)
            locationContinuation = nil
        default:
            break
        }
    }
}
