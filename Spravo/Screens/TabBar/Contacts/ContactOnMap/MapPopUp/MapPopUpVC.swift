//
//  MapPopUpVC.swift
//  Spravo
//
//  Created by Onix on 11/21/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import MapKit

enum MapPopUpButtonType {
    case mapType(Int)
}

protocol MapPopUpVCButtonActionDelegate: class {
    func buttonInTableViewTaped(_ btnType: MapPopUpButtonType, indexPath: IndexPath?)
}

protocol PopUpMapDelegate {
    func hidePopUp()
    func setMapType(_ to: Int)
    func route(_ by: Int, completion: @escaping (_ routes: [MapRoute]?) -> ())
    func setPopUpHeight(_ routeIsOpen: Bool?)
}

class MapPopUpVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel = MapPopUpViewModel()
    var delegate: PopUpMapDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
    }
    
    func setupView() {
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
    }
    
    @IBAction func backToMapButtonTaped(_ sender: AnyObject) {
        delegate?.hidePopUp()
    }
}

extension MapPopUpVC: UITableViewDataSource {
    private func setupTableView() {
        viewModel.registerCells(for: tableView)
        
        tableView.tableFooterView = UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.getNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRows(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = viewModel.cellForTableView(tableView: tableView, atIndexPath: indexPath, buttonsDelegate: self)
        return cell
    }
}

extension MapPopUpVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectRowAt(indexPath) { [weak self] in
            self?.tableView.reloadData { [weak self] in
                self?.delegate?.setPopUpHeight(self?.viewModel.routeIsOpen())
            }
        }
    }
}

extension MapPopUpVC: MapPopUpVCButtonActionDelegate {
    func buttonInTableViewTaped(_ btnType: MapPopUpButtonType, indexPath: IndexPath?) {
        let tapedBtn = (btnType, (indexPath?.row ?? 999))
        switch tapedBtn {
        case (.mapType(let type), 0):
            delegate?.setMapType(type)
        case (.mapType(let type), 1):
            delegate?.route(type) { [weak self] routes in
                self?.viewModel.setRoutes([])
                guard let routes = routes else { return }
                self?.viewModel.setRoutes(routes)
                self?.tableView.reloadData { [weak self] in
                    self?.delegate?.setPopUpHeight(self?.viewModel.routeIsOpen())
                }
            }
        default: break
        }
    }
}
