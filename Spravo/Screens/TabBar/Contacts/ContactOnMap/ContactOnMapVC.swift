//
//  ContactOnMapVC.swift
//  Spravo
//
//  Created by Onix on 11/18/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import MapKit

class ContactOnMapVC: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    var viewModel: ContactOnMapViewModelType!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setLocationPin()
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.mapType = .mutedStandard
        if mapView.subviews.count > 1 {
            mapView.subviews[1].isHidden = true
        }
    }
    
    private func setLocationPin() {
        viewModel.getAddressCoordinate { (coordinate, error) in
            guard let coordinate = coordinate, error == nil else { return }
            updateUIonMainThread { [weak self] in
                guard let self = self else { return }
                let anno = MKPointAnnotation()
                anno.coordinate = coordinate
                self.mapView.addAnnotation(anno)
                let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                self.mapView.setRegion(region, animated: false)
                self.mapView.showsUserLocation = true
            }
        }
    }
}

extension ContactOnMapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return viewModel.getMKAnnotationView(annotation)
    }
}
