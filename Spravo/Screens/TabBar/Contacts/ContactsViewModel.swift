//
//  ContactsViewModel.swift
//  Spravo
//
//  Created by Onix on 10/30/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
protocol ContactsViewModelType {
    func getContacts(completion: @escaping (ResultE<String?>) -> ())
    func registerCells(for tableView: UITableView)
    func getNumberOfSections() -> Int
    func getTitleForHeaderInSection(section: Int) -> String
    func getSectionIndexTitles() -> [String]?
    func getNumberOfRows(section: Int) -> Int
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    func search(searchText: String)
}

class ContactsViewModel: ContactsViewModelType {
    fileprivate let coordinator: ContactsCoordinatorType
    private var serviceHolder: ServiceHolder
    private var contactsProvider: ContactsProvider
    private var firebaseAgent: FirebaseAgent
    
    private var contactsDictionary = [String: [Contact]]()
    private var contactsSections = [String]()
    
    init(_ coordinator: ContactsCoordinatorType, serviceHolder: ServiceHolder) {
        self.coordinator = coordinator
        self.serviceHolder = serviceHolder
        self.contactsProvider = serviceHolder.get(by: ContactsProvider.self)
        self.firebaseAgent = serviceHolder.get(by: FirebaseAgent.self)
    }
    
    func getContacts(completion: @escaping (ResultE<String?>) -> ()) {
        DispatchQueue.global().async { [weak self] in
            let error = NSLocalizedString("Contacts.ErrorCopyFromFb", comment: "Error copying contacts form Firebase")
            guard let self = self, let userFbId = self.contactsProvider.user.facebookId else {
                completion(.failure(error))
                return
            }
            self.firebaseAgent.getAllContacts(userFbId: userFbId) { [weak self] fbContacts in
                guard let self = self, let fbContacts = fbContacts else {
                    completion(.failure(error))
                    return
                }
                self.contactsProvider.contactModels = fbContacts
                self.sortСontacts()
                completion(.success)
            }
        }
    }
    
    fileprivate func sortСontacts(_ searchText: String? = nil) {
        var arrContacts = contactsProvider.contactModels
        contactsDictionary = [:]
        contactsSections = []
        if let searchText = searchText, !searchText.isEmpty   {
            arrContacts = arrContacts.filter({ contact -> Bool in
                    ((contact.givenName ?? "").lowercased().contains(searchText.lowercased()) ||
                        (contact.familyName ?? "").lowercased().contains(searchText.lowercased()))
                })
        }
        for contact in arrContacts {
            let contKey = contact.namePrefix
            if var sectArr = contactsDictionary[contKey] {
                sectArr.append(contact)
                contactsDictionary[contKey] = sectArr
            } else {
                contactsDictionary[contKey] = [contact]
            }
        }
        contactsSections = [String](contactsDictionary.keys)
        contactsSections = contactsSections.sorted(by: < )
    }
    
    func startFetchPhoneContacts() {
        coordinator.startFetchPhoneContacts()
    }
}

extension ContactsViewModel {
    func registerCells(for tableView: UITableView) {
        tableView.register(UINib(nibName: ContactsCell.identifier, bundle: nil), forCellReuseIdentifier: ContactsCell.identifier)
    }
    
    func getNumberOfSections() -> Int {
        return contactsSections.count
    }
    
    func getTitleForHeaderInSection(section: Int) -> String {
        return section < contactsSections.count ? contactsSections[section] : "?"
    }
    
    func getSectionIndexTitles() -> [String]? {
        return contactsSections
    }
    
    func getNumberOfRows(section: Int) -> Int {
        let contKey = contactsSections[section]
        guard let sectArr = contactsDictionary[contKey] else { return 0}
        return sectArr.count
    }
    
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactsCell.identifier, for: indexPath) as? ContactsCell
        let contKey = contactsSections[indexPath.section]
        if let sectArr = contactsDictionary[contKey], indexPath.row < sectArr.count {
            let model = sectArr[indexPath.row]
            cell?.customInit(contact: model)
        }
        return cell ?? UITableViewCell()
    }
}

extension ContactsViewModel {
    func search(searchText: String) {
        sortСontacts(searchText)
    }
}
