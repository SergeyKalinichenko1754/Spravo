//
//  MapPopUpViewModel.swift
//  Spravo
//
//  Created by Onix on 11/21/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import MapKit

protocol MapPopUpViewModelType {
    func registerCells(for tableView: UITableView)
    func getNumberOfSections() -> Int
    func getNumberOfRows(_ section: Int) -> Int
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath, buttonsDelegate: MapPopUpVCButtonActionDelegate) -> UITableViewCell
    func setRoutes(_ routes: [MapRoute])
    func routeIsOpen() -> Bool?
    func didSelectRowAt(_ indexPath: IndexPath, completion: @escaping EmptyClosure)
}

class MapPopUpViewModel: MapPopUpViewModelType {
    
    private var routes: [MapRoute] = []
    
    func registerCells(for tableView: UITableView) {
        tableView.register(UINib(nibName: MapPopUpMapTypeCell.identifier, bundle: nil), forCellReuseIdentifier: MapPopUpMapTypeCell.identifier)
        tableView.register(UINib(nibName: MapPopUpRouteCell.identifier, bundle: nil), forCellReuseIdentifier: MapPopUpRouteCell.identifier)
        tableView.register(UINib(nibName: MapPopUpRouteStepCell.identifier, bundle: nil), forCellReuseIdentifier: MapPopUpRouteStepCell.identifier)
    }
    
    func getNumberOfSections() -> Int {
        return 1 + routes.count
    }
    
    func getNumberOfRows(_ section: Int) -> Int {
        guard section > 0 else { return 2}
        guard routes.count >= section else { return 0}
        return routes[section - 1].open ? routes[section - 1].route.steps.count + 1 : 1
    }
    
    func setRoutes(_ routes: [MapRoute]) {
        self.routes = routes
    }
    
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath, buttonsDelegate: MapPopUpVCButtonActionDelegate) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MapPopUpMapTypeCell.identifier, for: indexPath) as? MapPopUpMapTypeCell else { return UITableViewCell()}
            cell.segmentedButton.removeAllSegments()
            cell.label.text = NSLocalizedString("MapPopUp.MapTypeLabelText", comment: "text for mapType Label")
            var btnCaption = NSLocalizedString("MapPopUp.MapTypeStandard", comment: "standard (map type)")
            cell.segmentedButton.insertSegment(withTitle: btnCaption, at: 0, animated: false)
            btnCaption = NSLocalizedString("MapPopUp.MapTypeSatellite", comment: "satellite (map type)")
            cell.segmentedButton.insertSegment(withTitle: btnCaption, at: 1, animated: false)
            cell.segmentedButton.selectedSegmentIndex = 0
            cell.delegate = buttonsDelegate
            cell.indexPath = indexPath
            cell.backgroundColor = .clear
            return cell
        case (0, 1):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MapPopUpMapTypeCell.identifier, for: indexPath) as? MapPopUpMapTypeCell else { return UITableViewCell()}
            cell.segmentedButton.removeAllSegments()
            cell.label.text = NSLocalizedString("MapPopUp.MapRouteLabel", comment: "text for route Label")
            cell.segmentedButton.insertSegment(withTitle: "🚶🏼‍♂️", at: 0, animated: false)
            cell.segmentedButton.insertSegment(withTitle: "🚙", at: 1, animated: false)
            cell.delegate = buttonsDelegate
            cell.indexPath = indexPath
            cell.backgroundColor = .clear
            return cell
        case (let s, 0) where s > 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MapPopUpRouteCell.identifier, for: indexPath) as? MapPopUpRouteCell else { return UITableViewCell()}
            let route = routes[s - 1]
            cell.colorView.backgroundColor = route.color
            cell.estimatedTimeLabel.text = route.route.expectedTravelTime.asString(style: .abbreviated)
            cell.routeNameLabel.text = route.route.distance.metersIsStringInKm() + " : " + route.route.name
            cell.backgroundColor = .clear
            return cell
        case (let s, let r) where s > 0 && r > 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MapPopUpRouteStepCell.identifier, for: indexPath) as? MapPopUpRouteStepCell else { return UITableViewCell()}
            let step = routes[s - 1].route.steps[r - 1]
            cell.stepLabel.text = step.distance.metersIsStringInKm() + " : " + step.instructions + " " + (step.notice ?? "")
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func routeIsOpen() -> Bool? {
        guard routes.count > 0 else { return nil}
        guard let _ = routes.first(where: { $0.open }) else { return false}
        return true
    }
}

extension MapPopUpViewModel {
    func didSelectRowAt(_ indexPath: IndexPath, completion: @escaping EmptyClosure) {
        switch (indexPath.section, indexPath.row) {
        case (let s, 0) where s > 0:
            guard routes.count >= s else { return}
            routes[s - 1].open = !routes[s - 1].open
            completion()
        default: break
        }
    }
}
