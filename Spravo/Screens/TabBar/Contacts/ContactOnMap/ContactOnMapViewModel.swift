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
    func getAddressCoordinate(completion: @escaping (_ coordinate: CLLocationCoordinate2D?, _ error: String?) -> ())
    func getMKAnnotationView(_ annotation: MKAnnotation) -> MKAnnotationView
}

class ContactOnMapViewModel: ContactOnMapViewModelType {
    private let coordinator : ContactOnMapCoordinatorType
    private var contact: Contact
    private var addressNumber: Int
    
    init(coordinator: ContactOnMapCoordinatorType, contact: Contact, addressNumber: Int) {
        self.coordinator = coordinator
        self.contact = contact
        self.addressNumber = addressNumber
    }
        
    func getAddressCoordinate(completion: @escaping (_ coordinate: CLLocationCoordinate2D?, _ error: String?) -> ()) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let address = self.contact.addresses?[self.addressNumber].address() else { return }
            let geocoder = CLGeocoder()
            let cleanedAddress = address.filter { !"\n\t\r".contains($0) }
            geocoder.geocodeAddressString(cleanedAddress) { (placemarks, error) in
                completion(placemarks?.first?.location?.coordinate, error?.localizedDescription)
            }
        }
    }
    
    func getMKAnnotationView(_ annotation: MKAnnotation) -> MKAnnotationView {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "PinForMapView")
        annotationView.image = UIImage(named: "redPin")
        return annotationView
    }
}
