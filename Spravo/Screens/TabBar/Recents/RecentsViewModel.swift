//
//  RecentsViewModel.swift
//  Spravo
//
//  Created by Onix on 10/30/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol RecentsViewModelType {
    func registerCells(for tableView: UITableView)
    func getNumberOfRows(section: Int) -> Int
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath, buttonsDelegate: RecentsVCButtonActionDelegate) -> UITableViewCell
    func deleteRow(_ row: Int)
}

class RecentsViewModel: RecentsViewModelType {
    fileprivate let coordinator: RecentsCoordinatorType
    private var contactsProvider: ContactsProvider
    private var communicationProvider: CommunicationProvider
    private var serviceHolder: ServiceHolder
    
    init(_ coordinator: RecentsCoordinatorType, serviceHolder: ServiceHolder) {
        self.coordinator = coordinator
        self.serviceHolder = serviceHolder
        self.contactsProvider = serviceHolder.get(by: ContactsProvider.self)
        self.communicationProvider = serviceHolder.get(by: CommunicationProvider.self)
    }
}

extension RecentsViewModel {
    func registerCells(for tableView: UITableView) {
        tableView.register(UINib(nibName: RecentsCell.identifier, bundle: nil), forCellReuseIdentifier: RecentsCell.identifier)
    }
    
    func getNumberOfRows(section: Int) -> Int {
        return contactsProvider.recentsCount()
    }
    
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath, buttonsDelegate: RecentsVCButtonActionDelegate) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecentsCell.identifier, for: indexPath) as? RecentsCell,
            let recent = contactsProvider.getRecent(indexPath.row) else { return UITableViewCell() }
        cell.delegate = buttonsDelegate
        cell.indexPath = indexPath
        cell.callConnectStateImageView.image = nil
        switch recent.type {
        case .phone:
            cell.typeImage.image = UIImage(named: "callImage")
            cell.callConnectStateImageView.image = recent.beganTalkDate == nil ? UIImage(named: "cancelMark") : UIImage(named: "okMark")
        case .sms:
            cell.typeImage.image = UIImage(named: "smsImage")
        case .email:
            cell.typeImage.image = UIImage(named: "emailImage")
        }
        if let contact = contactsProvider.getContact(recent.id),
            let contactItem = recent.type == .email ?
                contact.emails?.first(where: { $0.value == recent.recipient}) :
                contact.phones?.first(where: { $0.value == recent.recipient}) {
            cell.typeLabel.text = recent.type == .email ? contactItem.emailLbl() : contactItem.phoneLbl()
            cell.valueLabel.text = contact.fullName
            
        } else {
            cell.typeLabel.text = ""
            cell.valueLabel.text = recent.recipient
        }
        var dateString = ""
        if let date = recent.completionDate {
            dateString = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
        }
        cell.dateLabel.text = dateString
        return cell
    }
}

extension RecentsViewModel {
    func showContactDetails(_ index: IndexPath) {
        guard let recent = contactsProvider.getRecent(index.row),
            let contact = contactsProvider.getContact(recent.id) else { return }
        coordinator.showContactDetails(contact)
    }
    
    func deleteRow(_ row: Int) {
        contactsProvider.deleteRecent(row)
    }
}
