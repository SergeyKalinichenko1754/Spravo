//
//  UserLocationServiceType.swift
//  Spravo
//
//  Created by Onix on 11/18/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation
import CoreLocation

protocol UserLocationServiceType: Service {
    var callBackUserAddressWasChanged: SimpleClosure<String>? { get set }
    var userLocation: CLLocationCoordinate2D? { get }
    var userAddress: String? { get }
}

class UserLocationService: NSObject, UserLocationServiceType {
    private var locationManager: CLLocationManager?
    private var lastUserLocation: CLLocationCoordinate2D?
    private var lastUserAddress: String?
    
    var callBackUserAddressWasChanged: SimpleClosure<String>?
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter =  kCLDistanceFilterNone
        locationManager?.delegate = self
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.locationManager?.requestWhenInUseAuthorization()
            }
        } else if status != .denied && status != .restricted {
            locationManager?.startUpdatingLocation()
        } else {
            debugPrint("Status UserLocationService: \(status)")
        }
    }    
}

extension UserLocationService {
    var userLocation: CLLocationCoordinate2D? {
        return lastUserLocation
    }
    
    var userAddress: String? {
        return lastUserAddress ?? "n/a"
    }
}

extension UserLocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager?.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastUserLocation = locations.last?.coordinate
        updateUserAddress(locations.last)
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AlertHelper.showAlert(msg: error.localizedDescription)
    }
}

extension UserLocationService {
    private func updateUserAddress(_ location: CLLocation?) {
        guard let location = location else { return }
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] (places, error) in
            if let place = places?.first {
                if let address = self?.makeAddressString(place: place) {
                    self?.lastUserAddress = address
                    self?.callBackUserAddressWasChanged?(address)
                }
            }
        }
    }
    
    private func makeAddressString(place: CLPlacemark) -> String {
        let items = [place.country, place.locality, place.thoroughfare, place.subThoroughfare].compactMap( { $0 })
        let address = items.joined(separator: ", ")
        return address
    }
}
