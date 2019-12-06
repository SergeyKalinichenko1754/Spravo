//
//  ContactOnMapVC.swift
//  Spravo
//
//  Created by Onix on 11/18/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import MapKit


struct MapRoute {
    var open: Bool
    let color: UIColor
    let route: MKRoute
}

class ContactOnMapVC: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var showUserLocationButton: UIButton!
    @IBOutlet weak var showAddressLocationButton: UIButton!
    @IBOutlet weak var showPopUpButton: UIButton!
    @IBOutlet weak var popUpConteiner: UIView!
    @IBOutlet weak var popUpConteinerHeight: NSLayoutConstraint!
    
    var viewModel: ContactOnMapViewModelType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setPinForAddress()
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = DefaultColors.navigationBarBackgroundColor
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.mapType = .mutedStandard
        if mapView.subviews.count > 1 {
            mapView.subviews[1].isHidden = true
        }
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    private func setPinForAddress() {
        viewModel.getPinAddressCoordinate { (coordinate, error) in
            guard let coordinate = coordinate, error == nil else { return }
            updateUIonMainThread { [weak self] in
                guard let self = self else { return }
                let anno = MKPointAnnotation()
                anno.title = self.viewModel.getPinAddress()
                anno.coordinate = coordinate
                self.mapView.addAnnotation(anno)
                let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                self.mapView.setRegion(region, animated: false)
                self.setupRightBottomNavigationButtons()
            }
        }
    }
    
    private func setupRightBottomNavigationButtons() {
        guard popUpConteiner.isHidden else {
            showUserLocationButton.isHidden = true
            showAddressLocationButton.isHidden = true
            return
        }
        if let userLocationCoordinate = viewModel.getUserLocationCoordinate() {
            showUserLocationButton.isHidden = mapView.contains(coordinate: userLocationCoordinate)
        }
        guard let pinCoordinate = viewModel.getPinCoordinate() else { return }
        showAddressLocationButton.isHidden = mapView.contains(coordinate: pinCoordinate)
    }
    
    private func showRegion(_ withCenter: CLLocationCoordinate2D?) {
        guard let coordinate = withCenter else { return }
        let region = MKCoordinateRegion(center: coordinate, span: mapView.region.span)
        self.mapView.setRegion(region, animated: true)
        self.setupRightBottomNavigationButtons()
    }
    
    private func popUPisVisible(_ isVisible: Bool? = true) {
        popUpConteiner.isHidden = !(isVisible ?? true)
        showPopUpButton.isHidden = isVisible ?? true
        setupRightBottomNavigationButtons()
    }
    
    @IBAction func backButtonTaped(_ sender: UIButton) {
        viewModel.backTaped()
    }
    
    @IBAction func showUserLocationButtonTaped(_ sender: UIButton) {
        showRegion(viewModel.getUserLocationCoordinate())
    }
    
    @IBAction func showAddressLocationButtonTaped(_ sender: UIButton) {
        showRegion(viewModel.getPinCoordinate())
    }
    
    @IBAction func popUpButtonTaped(_ sender: UIButton) {
        popUPisVisible()
    }
}

extension ContactOnMapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return viewModel.getMKAnnotationView(annotation)
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        setupRightBottomNavigationButtons()
    }
}

extension ContactOnMapVC: PopUpMapDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToMapPopUpVC" {
            let popUpController = segue.destination as! MapPopUpVC
            popUpController.delegate = self
        }
    }
    
    func hidePopUp() {
        popUPisVisible(false)
    }
    
    func setMapType(_ to: Int) {
        switch to {
        case 1:
            mapView.mapType = .satellite
        default:
            mapView.mapType = .standard
        }
    }
    
    func route(_ by: Int, completion: @escaping (_ routes: [MapRoute]?) -> ()) {
        guard let to = viewModel.getPinCoordinate() else { return }
        guard let from = viewModel.getUserLocationCoordinate() else {
            showSettingsAlert()
            return
        }
        HUDRenderer.showHUD()
        let transport: MKDirectionsTransportType = by == 0 ? .walking : .automobile
        viewModel.getRoute(from: from, to: to, by: transport) { [weak self] (response, error) in
            guard let self = self, let response = response else {
                HUDRenderer.hideHUD()
                if let error = error {
                    AlertHelper.showAlert(error)
                }
                return
            }
            var routesArr: [MapRoute] = []
            let overlays = self.mapView.overlays
            self.mapView.removeOverlays(overlays)
            for route in response.routes {
                self.mapView.addOverlay(route.polyline, level : .aboveRoads)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                let route = MapRoute(open: false, color: self.viewModel.getLastStrokeColor(), route: route)
                routesArr.append(route)
            }
            completion(routesArr)
            HUDRenderer.hideHUD()
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = viewModel.getStrokeColor()
        renderer.lineWidth = 2.5
        renderer.alpha = 0.5
        return renderer
    }
    
    private func showSettingsAlert() {
        let msg = NSLocalizedString("MapPopUp.AskForPermission", comment: "Message that the program needs access to location")
        let leftButtonCaption = NSLocalizedString("MapPopUp.AskForPermissionCancelButtonCaption", comment: "Cancel button caption")
        let rightBittonCaption = NSLocalizedString("MapPopUp.AskForPermissionOpenSettingsButtonCaption", comment: "OpenSettings button caption")
        AlertHelper.showAlert(msg: msg, from: self, leftBtnTitle: leftButtonCaption, rightBtnTitle: rightBittonCaption) { (result) in
            if result {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
        }
    }
    
    func setPopUpHeight(_ routeIsOpen: Bool?) {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let self = self else { return }
            var multiplier: CGFloat = 0.3
            if let routeIsOpen = routeIsOpen {
                multiplier = routeIsOpen ? 1 : 0.5
            }
            NSLayoutConstraint.setMultiplier(multiplier, of: &self.popUpConteinerHeight)
            self.view.layoutIfNeeded()
        })
    }
}