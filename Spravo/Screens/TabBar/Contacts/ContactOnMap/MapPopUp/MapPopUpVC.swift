//
//  MapPopUpVC.swift
//  Spravo
//
//  Created by Onix on 11/21/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

enum MapPopUpButtonType {
    case mapType(Int)
}

protocol MapPopUpVCButtonActionDelegate: class {
    func buttonInTableViewTaped(_ btnType: MapPopUpButtonType, indexPath: IndexPath?)
}

protocol PopUpMapDelegate {
    func hidePopUp()
    func setMapType(_ to: Int)
    func route(_ by: Int)
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
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
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
    }
}

extension MapPopUpVC: MapPopUpVCButtonActionDelegate {
    func buttonInTableViewTaped(_ btnType: MapPopUpButtonType, indexPath: IndexPath?) {
        let tapedBtn = (btnType, (indexPath?.row ?? 999))
        switch tapedBtn {
        case (.mapType(let type), 0):
            delegate?.setMapType(type)
        case (.mapType(let type), 1):
            delegate?.route(type)
        default: break
        }
    }
}
