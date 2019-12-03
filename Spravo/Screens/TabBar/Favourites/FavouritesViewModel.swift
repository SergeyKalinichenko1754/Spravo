//
//  FavouritesViewModel.swift
//  Spravo
//
//  Created by Onix on 10/30/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol FavouritesViewModelType {
    func registerCells(for tableView: UITableView)
    func getNumberOfRows(section: Int) -> Int
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath, buttonsDelegate: FavouritesVCButtonActionDelegate) -> UITableViewCell
    func moveRow(from: Int, to: Int)
    func deleteRow(_ row: Int)
    func openCommunicationVC(_ index: IndexPath, inVC: UIViewController)
    func getTemplateForFixingCommunication(_ index: IndexPath) -> Recent?
    func addToRecent(_ new: Recent)
}

class FavouritesViewModel: FavouritesViewModelType {
    private let coordinator: FavouritesCoordinatorType
    private var contactsProvider: ContactsProvider
    private var communicationProvider: CommunicationProvider
    private var serviceHolder: ServiceHolder
    private var imageLoader: ImageLoader
    
    init(_ coordinator: FavouritesCoordinatorType, serviceHolder: ServiceHolder) {
        self.coordinator = coordinator
        self.serviceHolder = serviceHolder
        self.contactsProvider = serviceHolder.get(by: ContactsProvider.self)
        self.communicationProvider = serviceHolder.get(by: CommunicationProvider.self)
        self.imageLoader = serviceHolder.get(by: ImageLoader.self)
    }
}

extension FavouritesViewModel {
    func registerCells(for tableView: UITableView) {
        tableView.register(UINib(nibName: FavouritesCell.identifier, bundle: nil), forCellReuseIdentifier: FavouritesCell.identifier)
    }
    
    func getNumberOfRows(section: Int) -> Int {
        return contactsProvider.favouritesCount()
    }
    
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath, buttonsDelegate: FavouritesVCButtonActionDelegate) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavouritesCell.identifier, for: indexPath) as? FavouritesCell,
        let favourite = contactsProvider.getFavourite(indexPath.row) else { return UITableViewCell() }
        cell.delegate = buttonsDelegate
        cell.indexPath = indexPath
        switch favourite.type {
        case .phone:
          cell.typeImage.image = UIImage(named: "callImage")
        case .sms:
            cell.typeImage.image = UIImage(named: "smsImage")
        case .email:
            cell.typeImage.image = UIImage(named: "emailImage")
        }
        if let contact = contactsProvider.getContact(favourite.id),
            let contactItem = favourite.type == .email ?
                contact.emails?.first(where: { $0.value == favourite.favourite}) :
                contact.phones?.first(where: { $0.value == favourite.favourite}) {
            cell.headerLabel.text = favourite.type == .email ? contactItem.emailLbl() : contactItem.phoneLbl()
            cell.valueLabel.text = contact.fullName
            cell.prefixLabel.text = contact.fullNamePrefix
            cell.prefixLabel.isHidden = false
            if let urlImage = contact.profileImage {
                imageLoader.loadImage(urlString: urlImage, indexPath: indexPath) { (index, image) in
                    updateUIonMainThread {
                        guard let image = image, let index = index,
                            let thisCell = tableView.cellForRow(at: index) as? FavouritesCell else { return }
                        thisCell.prefixLabel.isHidden = true
                        thisCell.profileImage.image = image
                    }
                }
            }
        } else {
            cell.profileImage.image = UIImage(named: "unknownContact")
            cell.prefixLabel.text = ""
            cell.headerLabel.text = ""
            cell.valueLabel.text = favourite.favourite
        }
        return cell
    }
}

extension FavouritesViewModel {
    func showContactDetails(_ index: IndexPath) {
        guard let favourite = contactsProvider.getFavourite(index.row),
            let contact = contactsProvider.getContact(favourite.id) else { return }
        coordinator.showContactDetails(contact)
    }
}

extension FavouritesViewModel {
    func moveRow(from: Int, to: Int) {
        contactsProvider.moveFavourite(from: from, to: to)
    }
    
    func deleteRow(_ row: Int) {
        contactsProvider.deleteFavourite(row)
    }
}

extension FavouritesViewModel {
    func openCommunicationVC(_ index: IndexPath, inVC: UIViewController) {
        guard let favourite = contactsProvider.getFavourite(index.row) else { return }
        switch favourite.type {
        case .phone:
            communicationProvider.callToNumber(favourite.favourite)
        case .sms:
            communicationProvider.sendSMS(favourite.favourite, inVC: inVC)
        case .email:
            communicationProvider.sendEmail(favourite.favourite)
        }
    }
}

extension FavouritesViewModel {
    func getTemplateForFixingCommunication(_ index: IndexPath) -> Recent? {
        guard let favourite = contactsProvider.getFavourite(index.row) else { return nil }
        let newCommunication = Recent(beganTalkDate: nil, id: favourite.id, type: favourite.type, recipient: favourite.favourite, otherRecipients: nil, completionDate: nil)
        return newCommunication
    }
    
    func addToRecent(_ new: Recent) {
        contactsProvider.addRecent(new)
    }
}
