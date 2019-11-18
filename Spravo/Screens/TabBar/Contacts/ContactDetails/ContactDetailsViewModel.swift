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
    func didSelectRowAt(_ tableView: UITableView, indexPath: IndexPath, completion: @escaping (String?) ->())
    func backTaped()
    func editContact()
}

class ContactDetailsViewModel: ContactDetailsViewModelType {
    private let coordinator : ContactDetailsCoordinatorType
    private var contact: Contact
    private var imageLoader: ImageLoader
    
    init(coordinator: ContactDetailsCoordinatorType, serviceHolder: ServiceHolder, contact: Contact) {
        self.coordinator = coordinator
        self.contact = contact
        self.imageLoader = serviceHolder.get(by: ImageLoader.self)
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
            return 0
        default:
            return 0
        }
    }
    
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath, smsButtonDelegate: SendSMSButtonDelegate) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: ContactDetailsPhoneCell.identifier, for: indexPath) as? ContactDetailsPhoneCell
            cell?.headerLabel.text = "📞 " + (contact.phones?[indexPath.row].phoneLbl() ?? "")
            cell?.valueLabel.text = contact.phones?[indexPath.row].value
            cell?.smsButton.isHidden = false
            cell?.delegate = smsButtonDelegate
            return cell ?? UITableViewCell()
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: ContactDetailsPhoneCell.identifier, for: indexPath) as? ContactDetailsPhoneCell
            cell?.headerLabel.text = "📧 " + (contact.emails?[indexPath.row].emailLbl() ?? "")
            cell?.valueLabel.text = contact.emails?[indexPath.row].value
            cell?.smsButton.isHidden = true
            return cell ?? UITableViewCell()
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: ContactDetailsAddressCell.identifier, for: indexPath) as? ContactDetailsAddressCell
            cell?.headerLabel.text = contact.addresses?[indexPath.row].addressLbl()
            if let address = contact.addresses?[indexPath.row].address() {
                cell?.valueLabel.text = address
                let geocoder = CLGeocoder()
                let cleanedAddress = address.filter { !"\n\t\r".contains($0) }
                geocoder.geocodeAddressString(cleanedAddress) { (placemarks, error) in
                    guard let location = placemarks?.first?.location?.coordinate , error == nil else {
                        let emptyMap = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                        emptyMap.image = UIImage(named: "unknownLocation")
                        cell?.mapView.tag = -1
                        cell?.mapView.subviews[0].isHidden = true
                        cell?.mapView.addSubview(emptyMap)
                        return }
                    let anno = MKPointAnnotation()
                    anno.coordinate = location
                    cell?.mapView.addAnnotation(anno)
                    cell?.mapView.selectAnnotation(anno, animated: false)
                    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    let region = MKCoordinateRegion(center: location, span: span)
                    cell?.mapView.setRegion(region, animated: false)
                }
            }
            return cell ?? UITableViewCell()
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: ContactDetailsPhoneCell.identifier, for: indexPath) as? ContactDetailsPhoneCell
            cell?.headerLabel.text = NSLocalizedString("Contacts.Birthday", comment: "Label 'birthday'")
            var dateString = ""
            if let date = contact.birthday {
                dateString = DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .none)
            }
            cell?.valueLabel.text = dateString
            cell?.smsButton.isHidden = true
            return cell ?? UITableViewCell()
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: ContactDetailsNotesCell.identifier, for: indexPath) as? ContactDetailsNotesCell
            cell?.headerLabel.text = NSLocalizedString("Contacts.Notes", comment: "Label 'notes:'")
            cell?.textView.text = contact.notes
            return cell ?? UITableViewCell()
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
            completion(nil)
            return
        }
        imageLoader.loadImage(urlString: urlStr) { (index, image) in
            completion(image)
        }
    }
    
    func didSelectRowAt(_ tableView: UITableView, indexPath: IndexPath, completion: @escaping (String?) ->()) {
        switch indexPath.section {
        case 0:
            guard let number = contact.phones?[indexPath.row].value else { return }
            callToNumber(number)
        case 1:
            guard let email = contact.emails?[indexPath.row].value else { return }
            sendEmail(email)
        case 2:
            guard let cell = tableView.cellForRow(at: indexPath) as? ContactDetailsAddressCell, cell.mapView.tag >= 0 else {
                let error = NSLocalizedString("Contacts.AddressNotFoundError", comment: "Error: address not found (on the map)")
                completion(error)
                return }
            coordinator.showContactOnMap(contact: contact, addressNumber: indexPath.row)
        default: break
        }
    }
    
    private func callToNumber(_ number: String) {
        let shared = UIApplication.shared
        let phone = "tel://\(number)"
        let phoneFallback = "telprompt://\(number)"
        if let url = URL(string: phone), shared.canOpenURL(url) {
            shared.open(url, options: [:]) { success in
                debugPrint("Call to \(phone)")
            }
        } else if let fallbackURl = URL(string: phoneFallback), shared.canOpenURL(fallbackURl) {
            shared.open(fallbackURl, options: [:]) { success in
                debugPrint("Call to \(phoneFallback)")
            }
        } else {
            debugPrint("Unable to open url for call")
        }
    }
    
    private func sendEmail(_ email: String) {
        let shared = UIApplication.shared
        let mail = "mailto:\(email)"
        if let emailURl = URL(string: mail), shared.canOpenURL(emailURl) {
            shared.open(emailURl, options: [:]) { success in
                debugPrint("Send mail to \(mail)")
            }
        } else {
            debugPrint("Unable to open url for send mail")
        }
    }
    
    func backTaped() {
        coordinator.backTaped()
    }
    
    func editContact() {
        coordinator.editContact(contact)
    }
}
