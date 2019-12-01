//
//  MapPopUpViewModel.swift
//  Spravo
//
//  Created by Onix on 11/21/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol MapPopUpViewModelType {
    func registerCells(for tableView: UITableView)
    func getNumberOfRows(_ section: Int) -> Int
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath, buttonsDelegate: MapPopUpVCButtonActionDelegate) -> UITableViewCell
}

class MapPopUpViewModel: MapPopUpViewModelType {
    func registerCells(for tableView: UITableView) {
        tableView.register(UINib(nibName: MapPopUpMapTypeCell.identifier, bundle: nil), forCellReuseIdentifier: MapPopUpMapTypeCell.identifier)
    }
    
    func getNumberOfRows(_ section: Int) -> Int {
        return 2
    }
    
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath, buttonsDelegate: MapPopUpVCButtonActionDelegate) -> UITableViewCell {
        switch indexPath.row {
        case 0:
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
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MapPopUpMapTypeCell.identifier, for: indexPath) as? MapPopUpMapTypeCell else { return UITableViewCell()}
            cell.segmentedButton.removeAllSegments()
            cell.label.text = NSLocalizedString("MapPopUp.MapRouteLabel", comment: "text for route Label")
            cell.segmentedButton.insertSegment(withTitle: "🚶🏼‍♂️", at: 0, animated: false)
            cell.segmentedButton.insertSegment(withTitle: "🚙", at: 1, animated: false)
            cell.delegate = buttonsDelegate
            cell.indexPath = indexPath
            cell.backgroundColor = .clear
            return cell
        default:
            return UITableViewCell()
        }
    }
}
