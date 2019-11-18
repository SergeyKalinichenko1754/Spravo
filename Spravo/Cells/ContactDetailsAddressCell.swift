//
//  ContactDetailsAddressCell.swift
//  Spravo
//
//  Created by Onix on 11/15/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import MapKit

class ContactDetailsAddressCell: UITableViewCell {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mapView.delegate = self
        mapView.isUserInteractionEnabled = false
        if mapView.subviews.count > 1 {
            mapView.subviews[1].isHidden = true
        }
    }
}

extension ContactDetailsAddressCell: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "PinForMapView")
        annotationView.image = UIImage(named: "mapPin")
        return annotationView
    }
}
