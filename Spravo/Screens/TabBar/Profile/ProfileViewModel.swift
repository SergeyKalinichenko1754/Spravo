//
//  ProfileViewModel.swift
//  Spravo
//
//  Created by Onix on 10/30/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol ProfileViewModelType {
    func logout()
    func registerCells(for tableView: UITableView)
    func getNumberOfRows(section: Int) -> Int
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
}

class ProfileViewModel: ProfileViewModelType {
    fileprivate let coordinator: ProfileCoordinatorType
    private var serviceHolder: ServiceHolder
    
    init(_ coordinator: ProfileCoordinatorType, serviceHolder: ServiceHolder) {
        self.coordinator = coordinator
        self.serviceHolder = serviceHolder
    }
    
    func logout() {
        coordinator.logout()
    }
}

extension ProfileViewModel {
    func registerCells(for tableView: UITableView) {
        //tableView.register(UINib(nibName: RecentsCell.identifier, bundle: nil), forCellReuseIdentifier: RecentsCell.identifier)
    }
    
    func getNumberOfRows(section: Int) -> Int {
        return 10
    }
    
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
