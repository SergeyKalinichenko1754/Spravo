//
//  ContactDetailsViewModel.swift
//  Spravo
//
//  Created by Onix on 11/12/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import MapKit

protocol ContactDetailsViewModelType {
    func registerCells(for tableView: UITableView)
    func getNumberOfSections() -> Int
    func getNumberOfRows(section: Int) -> Int
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath, smsButtonDelegate: SendSMSButtonDelegate) -> UITableViewCell
    func getFullName() -> String
    func getProfileImage(completion: @escaping (UIImage?) ->())
    func didSelectRowAt(_ tableView: UITableView, indexPath: IndexPath, rootVC: UIViewController, completion: @escaping (String?) ->())
    func backTaped()
    func editContact()
    func sendSMS(_ to: String, inVC: UIViewController)
    func contactExist() -> Bool
    func dismissVC()
    func getTemplateForFixingCommunication(_ indexPath: IndexPath, sms: Bool) -> Recent?
    func addToRecent(_ new: Recent)
}

class ContactDetailsViewModel: ContactDetailsViewModelType {
    private let coordinator : ContactDetailsCoordinatorType
    private var contact: Contact
    private var contactsProvider: ContactsProvider
    private var communicationProvider: CommunicationProvider
    private var imageLoader: ImageLoader
    
    init(coordinator: ContactDetailsCoordinatorType, serviceHolder: ServiceHolder, contact: Contact) {
        self.coordinator = coordinator
        self.contact = contact
        self.contactsProvider = serviceHolder.get(by: ContactsProvider.self)
        self.imageLoader = serviceHolder.get(by: ImageLoader.self)
        self.communicationProvider = serviceHolder.get(by: CommunicationProvider.self)
    }
    
    func contactExist() -> Bool {
        guard let contactInStore = contactsProvider.getContact(contact.id) else { return false }
        contact = contactInStore
        return true
    }
    
    func dismissVC() {
        coordinator.backTaped()
    }
    
    func registerCells(for tableView: UITableView) {
        tableView.register(UINib(nibName: ContactDetailsPhoneCell.identifier, bundle: nil), forCellReuseIdentifier: ContactDetailsPhoneCell.identifier)
        tableView.register(UINib(nibName: ContactDetailsNotesCell.identifier, bundle: nil), forCellReuseIdentifier: ContactDetailsNotesCell.identifier)
        tableView.register(UINib(nibName: ContactDetailsAddressCell.identifier, bundle: nil), forCellReuseIdentifier: ContactDetailsAddressCell.identifier)
    }
    
    func getNumberOfSections() -> Int {
        return 6
    }
    
    func getNumberOfRows(section: Int) -> Int {
        switch section {
        case 0:
            return contact.phones?.count ?? 0
        case 1:
            return contact.emails?.count ?? 0
        case 2:
            return contact.addresses?.count ?? 0
        case 3:
            return contact.birthday != nil ? 1 : 0
        case 4:
            return contact.notes != nil ? 1: 0
        case 5:
            return contact.phones != nil || contact.emails != nil ? 1 : 0
        default:
            return 0
        }
    }
    
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath, smsButtonDelegate: SendSMSButtonDelegate) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactDetailsPhoneCell.identifier, for: indexPath) as? ContactDetailsPhoneCell else { return UITableViewCell() }
            cell.headerLabel.text = "📞 " + (contact.phones?[indexPath.row].phoneLbl() ?? "")
            cell.valueLabel.text = contact.phones?[indexPath.row].value
            cell.smsButton.isHidden = false
            cell.delegate = smsButtonDelegate
            cell.indexPath = indexPath
            cell.favouriteImage.isHidden = !contactsProvider.isContactFavourite(id: contact.id, item: contact.phones?[indexPath.row].value ?? "")
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactDetailsPhoneCell.identifier, for: indexPath) as? ContactDetailsPhoneCell else { return UITableViewCell() }
            cell.headerLabel.text = "📧 " + (contact.emails?[indexPath.row].emailLbl() ?? "")
            cell.valueLabel.text = contact.emails?[indexPath.row].value
            cell.smsButton.isHidden = true
            cell.favouriteImage.isHidden = !contactsProvider.isContactFavourite(id: contact.id, item: contact.emails?[indexPath.row].value ?? "")
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactDetailsAddressCell.identifier, for: indexPath) as? ContactDetailsAddressCell else { return UITableViewCell() }
            cell.headerLabel.text = contact.addresses?[indexPath.row].addressLbl()
            if let address = contact.addresses?[indexPath.row].address() {
                cell.valueLabel.text = address
                let geocoder = CLGeocoder()
                let cleanedAddress = address.filter { !"\n\t\r".contains($0) }
                geocoder.geocodeAddressString(cleanedAddress) { (placemarks, error) in
                    guard let location = placemarks?.first?.location?.coordinate , error == nil else {
                        let emptyMap = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                        emptyMap.image = UIImage(named: "unknownLocation")
                        cell.mapView.tag = -1
                        cell.mapView.subviews[0].isHidden = true
                        cell.mapView.addSubview(emptyMap)
                        return }
                    let anno = MKPointAnnotation()
                    anno.coordinate = location
                    cell.mapView.addAnnotation(anno)
                    cell.mapView.selectAnnotation(anno, animated: false)
                    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    let region = MKCoordinateRegion(center: location, span: span)
                    cell.mapView.setRegion(region, animated: false)
                }
            }
            return cell
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactDetailsPhoneCell.identifier, for: indexPath) as? ContactDetailsPhoneCell else { return UITableViewCell() }
            cell.favouriteImage.isHidden = true
            cell.headerLabel.text = NSLocalizedString("Contacts.Birthday", comment: "Label 'birthday'")
            var dateString = ""
            if let date = contact.birthday {
                dateString = DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .none)
            }
            cell.valueLabel.text = dateString
            cell.smsButton.isHidden = true
            return cell
        case 4:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactDetailsNotesCell.identifier, for: indexPath) as? ContactDetailsNotesCell else { return UITableViewCell() }
            cell.headerLabel.text = NSLocalizedString("Contacts.Notes", comment: "Label 'notes:'")
            cell.textView.text = contact.notes
            return cell
        case 5:
            let cell = UITableViewCell()
            cell.textLabel?.text = NSLocalizedString("Contacts.AddToFavoritesBtnCaption", comment: "Caption for Add to Favorites Button")
            cell.textLabel?.textColor = RGBColor(1, 25, 147)
            return cell
        default:
            let cell = UITableViewCell()
            cell.textLabel?.text = "Cell # \(indexPath.row)"
            return cell 
        }
    }

    func getFullName() -> String {
        return contact.fullName
    }
    
    func getProfileImage(completion: @escaping (UIImage?) ->()) {
        guard let urlStr = contact.profileImage else {
            completion(UIImage(named: "ContactWithoutPhoto"))
            return
        }
        imageLoader.loadImage(urlString: urlStr) { (index, image) in
            completion(image)
        }
    }
    
    func didSelectRowAt(_ tableView: UITableView, indexPath: IndexPath, rootVC: UIViewController, completion: @escaping (String?) ->()) {
        switch indexPath.section {
        case 0:
            guard let number = contact.phones?[indexPath.row].value else { return }
            communicationProvider.callToNumber(number)
        case 1:
            guard let email = contact.emails?[indexPath.row].value else { return }
            communicationProvider.sendEmail(email)
        case 2:
            guard let cell = tableView.cellForRow(at: indexPath) as? ContactDetailsAddressCell, cell.mapView.tag >= 0 else {
                let error = NSLocalizedString("Contacts.AddressNotFoundError", comment: "Error: address not found (on the map)")
                completion(error)
                return }
            coordinator.showContactOnMap(contact: contact, addressNumber: indexPath.row)
        case 5:
            whatAddToFavourite(rootVC)
        default: break
        }
    }
    
    func sendSMS(_ to: String, inVC: UIViewController) {
        communicationProvider.sendSMS(to, inVC: inVC)
    }
    
    func backTaped() {
        coordinator.backTaped()
    }
    
    func editContact() {
        coordinator.editContact(contact)
    }
    
    private func whatAddToFavourite(_ rootVC: UIViewController) {
        var title = NSLocalizedString("Contacts.AddToFavoritesBtnCaption", comment: "Caption for Add to Favorites Button")
        let popupVC = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        if let _ = contact.phones {
            popupVC.addAction(UIAlertAction(title: "📞 phone for call", style: .default, handler: { [weak self] (alert: UIAlertAction!) -> Void in
                self?.addToFavourite(what: .phone, rootVC: rootVC)
            }))
            popupVC.addAction(UIAlertAction(title: "💬 phone for sms", style: .default, handler: { [weak self] (alert: UIAlertAction!) -> Void in
                self?.addToFavourite(what: .sms, rootVC: rootVC)
            }))
        }
        if let _ = contact.emails {
            popupVC.addAction(UIAlertAction(title: "📧 email", style: .default, handler: { [weak self] (alert: UIAlertAction!) -> Void in
                self?.addToFavourite(what: .email, rootVC: rootVC)
            }))
        }
        title = NSLocalizedString("Contacts.SortBy.Cancel", comment: "Title for Cancel (Sort by)")
        popupVC.addAction(UIAlertAction(title: title, style: .cancel, handler: nil))
        rootVC.present(popupVC, animated: true, completion: nil)
    }
    
    private func addToFavourite(what: CommunicationType,rootVC: UIViewController) {
        guard let favouriteArray = what == .email ? contact.emails : contact.phones else { return }
        guard favouriteArray.count > 1 else {
            if let newFavourite = favouriteArray[0].value {
                let favourite = Favourite(id: contact.id, type: what, favourite: newFavourite)
                if !contactsProvider.isContactFavourite(favourite) {
                    contactsProvider.addFavourite(favourite)
                }
            }
            return
        }
        var title = NSLocalizedString("Contacts.AddToFavoritesBtnCaption", comment: "Caption for Add to Favorites Button")
        let popupVC = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        for favourite in favouriteArray {
            if let newFavourite = favourite.value {
                let favourite = Favourite(id: contact.id, type: what, favourite: newFavourite)
                if !contactsProvider.isContactFavourite(favourite) {
                    popupVC.addAction(UIAlertAction(title: newFavourite, style: .default, handler: { [weak self, favourite]
                        (alert: UIAlertAction!) -> Void in
                        guard let self = self else { return }
                        self.contactsProvider.addFavourite(favourite)
                    }))
                }
            }
        }
        guard popupVC.actions.count > 0 else { return }
        title = NSLocalizedString("Contacts.SortBy.Cancel", comment: "Title for Cancel (Sort by)")
        popupVC.addAction(UIAlertAction(title: title, style: .cancel, handler: nil))
        rootVC.present(popupVC, animated: true, completion: nil)
    }
}

extension ContactDetailsViewModel {
    func getTemplateForFixingCommunication(_ indexPath: IndexPath, sms: Bool) -> Recent? {
        var type = CommunicationType.sms
        if sms == false {
            type = indexPath.section == 0 ? .phone : .email
        }
        let recipient = indexPath.section == 0 ? (contact.phones?[indexPath.row].value ?? "") : (contact.emails?[indexPath.row].value ?? "")
        let newCommunication = Recent(beganTalkDate: nil, id: contact.id, type: type, recipient: recipient, otherRecipients: nil, completionDate: nil)
        return newCommunication
    }
    
    func addToRecent(_ new: Recent) {
        contactsProvider.addRecent(new)
    }
}
