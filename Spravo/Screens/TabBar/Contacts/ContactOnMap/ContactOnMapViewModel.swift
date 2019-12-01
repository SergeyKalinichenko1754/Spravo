//
//  ContactOnMapViewModel.swift
//  Spravo
//
//  Created by Onix on 11/18/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation
import MapKit

protocol ContactOnMapViewModelType {
    func backTaped()
    func getPinAddressCoordinate(completion: @escaping (_ coordinate: CLLocationCoordinate2D?, _ error: String?) -> ())
    func getMKAnnotationView(_ annotation: MKAnnotation) -> MKAnnotationView?
    func getPinAddress() -> String
    func getUserAddress() -> String
    func getPinCoordinate() -> CLLocationCoordinate2D?
    func getUserAddress(completion: @escaping SimpleClosure<String>)
    func getUserLocationCoordinate() -> CLLocationCoordinate2D?
    func getRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, by: MKDirectionsTransportType,
                  completion: @escaping (_ response: MKDirections.Response?, _ error: String?) -> ())
    func getStrokeColor() -> UIColor
}

class ContactOnMapViewModel: ContactOnMapViewModelType {
    private let coordinator : ContactOnMapCoordinatorType
    private var serviceHolder: ServiceHolder
    private var userLocationService: UserLocationServiceType
    private var contact: Contact
    private var addressNumber: Int
    private var addressCoordinate: CLLocationCoordinate2D?
    private var lastStrokeColor: UIColor = .black
    
    init(coordinator: ContactOnMapCoordinatorType, serviceHolder: ServiceHolder, contact: Contact, addressNumber: Int) {
        self.coordinator = coordinator
        self.serviceHolder = serviceHolder
        if !serviceHolder.isAdded(by: UserLocationService.self) {
            let userLocationService_ = UserLocationService()
            serviceHolder.add(UserLocationService.self, for: userLocationService_)
        }
        self.userLocationService = serviceHolder.get(by: UserLocationService.self)
        self.contact = contact
        self.addressNumber = addressNumber
    }
    
    func backTaped() {
        coordinator.backTaped()
    }
        
    func getPinAddressCoordinate(completion: @escaping (_ coordinate: CLLocationCoordinate2D?, _ error: String?) -> ()) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let address = self.contact.addresses?[self.addressNumber].address() else { return }
            let geocoder = CLGeocoder()
            let cleanedAddress = address.filter { !"\n\t\r".contains($0) }
            geocoder.geocodeAddressString(cleanedAddress) { [weak self] (placemarks, error) in
                guard let self = self else { return }
                let coordinate = placemarks?.first?.location?.coordinate
                self.addressCoordinate = coordinate
                completion(coordinate, error?.localizedDescription)
            }
        }
    }
    
    func getPinAddress() -> String {
        let address = self.contact.addresses?[self.addressNumber].address() ?? ""
        return address
    }
    
    func getPinCoordinate() -> CLLocationCoordinate2D? {
        return addressCoordinate
    }
    
    func getMKAnnotationView(_ annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pinForMapView")
        annotationView.canShowCallout = true
        annotationView.image = UIImage(named: "redPin")
        return annotationView
    }
    
    func getUserAddress() -> String {
        return userLocationService.userAddress ?? "n/a"
    }
    
    func getUserAddress(completion: @escaping SimpleClosure<String>) {
        userLocationService.callBackUserAddressWasChanged = completion
    }
    
    func getUserLocationCoordinate() -> CLLocationCoordinate2D? {
        return userLocationService.userLocation
    }
    
    func getRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, by: MKDirectionsTransportType,
                  completion: @escaping (_ response: MKDirections.Response?, _ error: String?) -> ()) {
        DispatchQueue.global().async {
            let sourcePlaceMark = MKPlacemark(coordinate: from)
            let destinationPlaceMark = MKPlacemark(coordinate: to)
            let directionRequest = MKDirections.Request()
            directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
            directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
            directionRequest.transportType = by
            directionRequest.requestsAlternateRoutes = true
            let directions = MKDirections(request: directionRequest)
            directions.calculate { (response, error) in
                completion(response, error?.localizedDescription)
            }
        }
    }
    
    func getStrokeColor() -> UIColor {
        var newStrokeColor: UIColor = .red
        switch lastStrokeColor {
        case .red:
            newStrokeColor = .blue
        case .blue:
            newStrokeColor = .purple
        case .purple:
            newStrokeColor = .cyan
        default:
            newStrokeColor = .red
        }
        lastStrokeColor = newStrokeColor
        return newStrokeColor
    }
}
