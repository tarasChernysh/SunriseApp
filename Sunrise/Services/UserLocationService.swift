//
//  UserLocationService.swift
//  Sunrise
//
//  Created by Macbook Air 13 on 5/7/19.
//  Copyright © 2019 Ihor Chernysh. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

final class UserLocationService: NSObject {
    private override init() {}
    
    // MARK: - Properties
    
    static let shared = UserLocationService()
    let locationManager = CLLocationManager()
    var currentCoordinate: ((CLLocationCoordinate2D) -> Void)?
    
    // MARK: - Helper Method
    
    func checkLocationAuthorizationStatus() -> Bool {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            if CLLocationManager.locationServicesEnabled() {
                setupDelegate()
                return true
            }
            print("notDetermined")
        case .restricted:
            print("restricted")
            return false
        case .denied:
            print("denied")
            return false
        case .authorizedAlways:
            print("authorizedAlways")
            return false
        case .authorizedWhenInUse:
            setupDelegate()
            return true
        @unknown default:
            print("other cases")
        }
        return false
    }
    
    private func setupDelegate() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate

extension UserLocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,
                                            longitude: userLocation.coordinate.longitude)
        currentCoordinate?(center)
        locationManager.stopUpdatingLocation()
    }
}


