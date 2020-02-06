//
//  MKMapView.swift
//  Spravo
//
//  Created by Onix on 11/19/19.
//  Copyright © 2019 Home. All rights reserved.
//

import MapKit

extension MKMapView {
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        return self.visibleMapRect.contains(MKMapPoint(coordinate))
    }
}
