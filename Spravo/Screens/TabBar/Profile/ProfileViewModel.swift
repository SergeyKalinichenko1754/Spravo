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
    func deleteAllContacts(completion: @escaping (_ error: String?) -> Void)
}

class ProfileViewModel: ProfileViewModelType {
    fileprivate let coordinator: ProfileCoordinatorType
    private var contactsProvider: ContactsProvider
    private var firebaseAgent: FirebaseAgent
    private var serviceHolder: ServiceHolder
    
    init(_ coordinator: ProfileCoordinatorType, serviceHolder: ServiceHolder) {
        self.coordinator = coordinator
        self.serviceHolder = serviceHolder
        self.contactsProvider = serviceHolder.get(by: ContactsProvider.self)
        self.firebaseAgent = serviceHolder.get(by: FirebaseAgent.self)
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
        return 1
    }
    
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = " Delete all contacts"
        return cell
    }
}

extension ProfileViewModel {
    func deleteAllContacts(completion: @escaping (_ error: String?) -> Void) {
        guard contactsProvider.contactsQuantity > 0 else { return }
        HUDRenderer.showHUD()
        let contacts = contactsProvider.contactModels
        var contactsQuantity = contacts.count
        let userFbId = contactsProvider.userFacebookId
        for contact in contacts {
            firebaseAgent.deleteContact(userFbId: userFbId, contact: contact)
            { [weak self] error in
                contactsQuantity -= 1
                self?.contactsProvider.removeContact(contact.id)
                if error != nil {
                    completion(error)
                    return
                } else if contactsQuantity == 0 {
                    completion(nil)
                    return
                }
            }
        }
    }
}
