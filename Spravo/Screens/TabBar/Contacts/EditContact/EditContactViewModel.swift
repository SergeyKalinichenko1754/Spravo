//
//  EditContactViewModel.swift
//  Spravo
//
//  Created by Onix on 11/17/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol EditContactViewModelType {
    func registerCells(for tableView: UITableView)
    func getNumberOfSections() -> Int
    func getNumberOfRows(section: Int) -> Int
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath, buttonDelegate: TVCellButtonActionAndTextFieldDelegate) -> UITableViewCell
    func getCurrentImage() -> UIImage?
    func setImageInCell(tableView: UITableView, atIndexPath indexPath: IndexPath, image: UIImage?, completion: @escaping (Bool) ->())
    func removeImageInCell(tableView: UITableView, atIndexPath indexPath: IndexPath)
    func didSelectRowAt(_ tableView: UITableView, indexPath: IndexPath, rootVC: UIViewController, completion: @escaping () ->())
    func textFieldDidChange(_ value: EditContactTextFieldType, indexPath: IndexPath?, tableView: UITableView)
    func trailingSwipeActions(_ tableView: UITableView, indexPath: IndexPath)-> UISwipeActionsConfiguration?
    func curentLabel(forIndexPath: IndexPath?, labelType: PopupMenuType) -> String?
    func setNewLabel(_ tableView: UITableView, newValue: String?, for labelType: PopupMenuType, forIndexPath: IndexPath?)
    func saveButtonIsEnabled() -> Bool
    func saveContact()
}

class EditContactViewModel: EditContactViewModelType {
    private let coordinator : EditContactCoordinatorType
    private var contact: Contact
    private var thisContactInStore: Contact?
    private var contactsProvider: ContactsProvider
    private var firebaseAgent: FirebaseAgent
    private var profileImage: UIImage?
    private var imageLoader: ImageLoader
    private var profileImageChanged = false
    
    init(coordinator: EditContactCoordinatorType, serviceHolder: ServiceHolder, contact: Contact) {
        self.coordinator = coordinator
        self.contact = contact
        self.contactsProvider = serviceHolder.get(by: ContactsProvider.self)
        self.firebaseAgent = serviceHolder.get(by: FirebaseAgent.self)
        self.imageLoader = serviceHolder.get(by: ImageLoader.self)
        thisContactInStore = contactsProvider.getContact(contact.id)
    }
}

extension EditContactViewModel {
    func registerCells(for tableView: UITableView) {
        tableView.register(UINib(nibName: EditContactPhotoNameCell.identifier, bundle: nil), forCellReuseIdentifier: EditContactPhotoNameCell.identifier)
        tableView.register(UINib(nibName: EditContactPhoneCell.identifier, bundle: nil), forCellReuseIdentifier: EditContactPhoneCell.identifier)
        tableView.register(UINib(nibName: EditContactAddFieldCell.identifier, bundle: nil), forCellReuseIdentifier: EditContactAddFieldCell.identifier)
        tableView.register(UINib(nibName: ContactDetailsPhoneCell.identifier, bundle: nil), forCellReuseIdentifier: ContactDetailsPhoneCell.identifier)
        tableView.register(UINib(nibName: EditContactAddressCell.identifier, bundle: nil), forCellReuseIdentifier: EditContactAddressCell.identifier)
        tableView.register(UINib(nibName: EditContactNotesCell.identifier, bundle: nil), forCellReuseIdentifier: EditContactNotesCell.identifier)
    }
    
    func getNumberOfSections() -> Int {
        return 7
    }
    
    func getNumberOfRows(section: Int) -> Int {
        switch section {
        case 1:
            return (contact.phones?.count ?? 0) + 1
        case 2:
            return (contact.emails?.count ?? 0) + 1
        case 3:
            return (contact.addresses?.count ?? 0) + 1
        case 6:
            return thisContactInStore == nil ? 0 : 1
        default:
            return 1
        }
    }
    
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath, buttonDelegate: TVCellButtonActionAndTextFieldDelegate) -> UITableViewCell {
        let emptyLabel = ".........."
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EditContactPhotoNameCell.identifier, for: indexPath) as? EditContactPhotoNameCell else { return UITableViewCell() }
            cell.delegate = buttonDelegate
            cell.indexPath = indexPath
            if profileImageChanged && profileImage == nil {
                let image = UIImage(named: "ContactWithoutPhoto")
                cell.profileImageButton.setImage(image, for: .normal)
            } else if let image = profileImage {
                cell.profileImageButton.setImage(image, for: .normal)
            } else if let urlImage = contact.profileImage {
                imageLoader.loadImage(urlString: urlImage, indexPath: indexPath) { (index, image) in
                    updateUIonMainThread { [weak self] in
                        guard let self = self, let image = image, let index = index,
                            let thisCell = tableView.cellForRow(at: index) as? EditContactPhotoNameCell else { return }
                        thisCell.profileImageButton.setImage(image, for: .normal)
                        self.profileImage = image
                    }
                }
            }
            cell.givenNameTextField.text = contact.givenName
            cell.givenNameTextField.placeholder = NSLocalizedString("EditContacts.GivenNameTextFieldPlaceholder", comment: "placeholder for given name text field")
            cell.middleNameTextField.text = contact.middleName
            cell.middleNameTextField.placeholder = NSLocalizedString("EditContacts.MiddleNameTextFieldPlaceholder", comment: "placeholder for middle name text field")
            cell.familyNameTextField.text = contact.familyName
            cell.familyNameTextField.placeholder = NSLocalizedString("EditContacts.LastNameTextFieldPlaceholder", comment: "placeholder for last name text field")
            return cell
        case 1:
            guard indexPath.row < (contact.phones?.count ?? 0) else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: EditContactAddFieldCell.identifier, for: indexPath) as? EditContactAddFieldCell else { return UITableViewCell() }
                cell.categoryLabel.text = NSLocalizedString("EditContacts.AddPhone", comment: "Label add phone")
                return cell
            }
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EditContactPhoneCell.identifier, for: indexPath) as? EditContactPhoneCell else { return UITableViewCell() }
            cell.delegate = buttonDelegate
            cell.indexPath = indexPath
            let title = contact.phones?[indexPath.row].phoneLbl() ?? emptyLabel
            cell.labelMarkButton.setTitle(title, for: .normal)
            cell.valueTextField.text = contact.phones?[indexPath.row].value
            return cell
        case 2:
            guard indexPath.row < (contact.emails?.count ?? 0) else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: EditContactAddFieldCell.identifier, for: indexPath) as? EditContactAddFieldCell else { return UITableViewCell() }
                cell.categoryLabel.text = NSLocalizedString("EditContacts.AddEmail", comment: "label add email")
                return cell
            }
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EditContactPhoneCell.identifier, for: indexPath) as? EditContactPhoneCell else { return UITableViewCell() }
            cell.delegate = buttonDelegate
            cell.indexPath = indexPath
            let title = contact.emails?[indexPath.row].emailLbl() ?? emptyLabel
            cell.labelMarkButton.setTitle(title, for: .normal)
            cell.valueTextField.text = contact.emails?[indexPath.row].value
            return cell
        case 3:
            guard indexPath.row < (contact.addresses?.count ?? 0) else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: EditContactAddFieldCell.identifier, for: indexPath) as? EditContactAddFieldCell else { return UITableViewCell() }
                cell.categoryLabel.text = NSLocalizedString("EditContacts.AddAddress", comment: "label add address")
                return cell
            }
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EditContactAddressCell.identifier, for: indexPath) as? EditContactAddressCell else { return UITableViewCell() }
            cell.delegate = buttonDelegate
            cell.indexPath = indexPath
            var title = contact.addresses?[indexPath.row].addressLbl() ?? emptyLabel
            cell.labelMarkButton.setTitle(title, for: .normal)
            cell.postalCodeTextField.text = contact.addresses?[indexPath.row].postalCode
            cell.streetTextField.text = contact.addresses?[indexPath.row].street
            cell.cityTextField.text = contact.addresses?[indexPath.row].city
            cell.stateTextField.text = contact.addresses?[indexPath.row].state
            title = contact.addresses?[indexPath.row].country() ?? emptyLabel
            cell.countryButton.setTitle(title, for: .normal)
            return cell
        case 4:
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
        case 5:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EditContactNotesCell.identifier, for: indexPath) as? EditContactNotesCell else { return UITableViewCell() }
            cell.delegate = buttonDelegate
            cell.indexPath = indexPath
            cell.headerLabel.text = NSLocalizedString("Contacts.Notes", comment: "Label 'notes:'")
            cell.textView.text = contact.notes
            return cell
        case 6:
            let cell = UITableViewCell()
            cell.textLabel?.text = NSLocalizedString("EditContacts.RemoveContactButtonCaption", comment: "Caption for Remove contact Button")
            cell.textLabel?.textColor = .red
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func curentLabel(forIndexPath: IndexPath?, labelType: PopupMenuType) -> String? {
        guard let indexPath = forIndexPath else { return nil}
        switch labelType {
        case .phoneLabel:
            return contact.phones?[indexPath.row].label
        case .emailLabel:
            return contact.emails?[indexPath.row].label
        case .addressLabel:
            return contact.addresses?[indexPath.row].label
        case .countryCode:
            return contact.addresses?[indexPath.row].isoCountryCode
        }
    }
    
    func setNewLabel(_ tableView: UITableView, newValue: String?, for labelType: PopupMenuType, forIndexPath: IndexPath?) {
        guard let indexPath = forIndexPath else { return }
        switch labelType {
        case .phoneLabel:
            contact.phones?[indexPath.row].label = newValue
        case .emailLabel:
            contact.emails?[indexPath.row].label = newValue
        case .addressLabel:
            contact.addresses?[indexPath.row].label = newValue
        case .countryCode:
            contact.addresses?[indexPath.row].isoCountryCode = newValue
        }
        reloadCell(tableView, rows: [indexPath])
    }
}

extension EditContactViewModel {
    func getCurrentImage() -> UIImage? {
        return profileImage
    }
    
    func setImageInCell(tableView: UITableView, atIndexPath indexPath: IndexPath, image: UIImage?, completion: @escaping (Bool) ->()) {
        switch indexPath.row {
        case 0:
            guard let image = image else { return }
            profileImage = image
            profileImageChanged = true
            completion(true)
            reloadCell(tableView, rows: [indexPath])
        default: break
        }
    }
    
    func removeImageInCell(tableView: UITableView, atIndexPath indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            profileImage = nil
            profileImageChanged = true
        default: break
        }
        reloadCell(tableView, rows: [indexPath])
    }
    
    private func reloadCell(_ tableView: UITableView, rows: [IndexPath]) {
        updateUIonMainThread {
            tableView.beginUpdates()
            tableView.reloadRows(at: rows, with: .fade)
            tableView.endUpdates()
        }
    }
    
    func didSelectRowAt(_ tableView: UITableView, indexPath: IndexPath, rootVC: UIViewController, completion: @escaping () ->()) {
        let opt = (indexPath.section, indexPath.row)
        switch opt {
        case (1, (contact.phones?.count ?? 0)), (2, (contact.emails?.count ?? 0)), (3, (contact.addresses?.count ?? 0)):
            addElement(indexPath)
            updateUIonMainThread {
                tableView.beginUpdates()
                tableView.insertRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
        case (4, 0):
            getDateByPicker(rootVC, currentDate: contact.birthday) { [weak self, tableView, indexPath] date in
                guard let self = self else { return }
                guard let date = date else {
                    self.contact.birthday = nil
                    self.reloadCell(tableView, rows: [indexPath])
                    completion()
                    return
                }
                self.contact.birthday = date
                self.reloadCell(tableView, rows: [indexPath])
                completion()
            }
        case (6, 0):
            let title = NSLocalizedString("EditContacts.DeleteContactQestion", comment: "Qestion: DeleteContact?")
            let leftBtnCaption = NSLocalizedString("EditContacts.RemoveContactButtonCaption", comment: "Remove Contact Button Caption")
            let rightBtnCaption = NSLocalizedString("Common.Cancel", comment: "Cancel")
            AlertHelper.showAlert(msg: title, from: rootVC, leftBtnTitle: leftBtnCaption, rightBtnTitle: rightBtnCaption)
            { [weak self] result in
                guard !result, let self = self, let clearedContact = self.clearedContact() else { return }
                HUDRenderer.showHUD()
                let userFbId = self.contactsProvider.userFacebookId
                self.firebaseAgent.deleteContact(userFbId: userFbId, contact: clearedContact, completion: { error in
                    if let error = error {
                        HUDRenderer.hideHUD()
                        let message = NSLocalizedString("EditContacts.Error.RemoveContactFromFirebase", comment: "error message (unable remove contact from Firebase)")
                        AlertHelper.showAlert(msg: message + error)
                        return
                    }
                    self.contactsProvider.removeContact(self.contact.id)
                    HUDRenderer.hideHUD()
                    self.coordinator.dissmisController()
                })
            }
        default: break
        }
    }
    
    func textFieldDidChange(_ value: EditContactTextFieldType, indexPath: IndexPath?, tableView: UITableView) {
        guard let indexPath = indexPath else { return }
        let opt = (value, indexPath.section, indexPath.row)
        switch opt {
        case (.notes(let text), _, _):
            contact.notes = text.clearedOptional
            updateUIonMainThread { [weak tableView] in
                guard let tableView = tableView else { return }
                UIView.setAnimationsEnabled(false)
                tableView.beginUpdates()
                tableView.endUpdates()
                UIView.setAnimationsEnabled(true)
            }
        case (.givenName(let text), _, _):
            contact.givenName = text.clearedOptional
        case (.middleName(let text), _, _):
            contact.middleName = text.clearedOptional
        case (.familyName(let text), _, _):
            contact.familyName = text.clearedOptional
        case (.oneTextFieldInCell(let text), 1, _):
            contact.phones?[indexPath.row].value = text.clearedOptional
        case (.oneTextFieldInCell(let text), 2, _):
            contact.emails?[indexPath.row].value = text.clearedOptional
        case (.postalCode(let text), 3, _):
            contact.addresses?[indexPath.row].postalCode = text.clearedOptional
        case (.street(let text), 3, _):
            contact.addresses?[indexPath.row].street = text.clearedOptional
        case (.city(let text), 3, _):
            contact.addresses?[indexPath.row].city = text.clearedOptional
        case (.state(let text), 3, _):
            contact.addresses?[indexPath.row].state = text.clearedOptional
        default: break
        }
    }
    
    private func getDateByPicker(_ rootVC: UIViewController, currentDate: Date?, completion: @escaping (Date?) ->()) {
        let datePicker = UIDatePicker(frame: CGRect(x: 5, y: 5, width: UIScreen.main.bounds.width - 20, height: 140))
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        if let localeId = Locale.preferredLanguages.first {
            datePicker.locale = Locale(identifier: localeId)
        }
        let alert = UIAlertController(title: "\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        alert.view.addSubview(datePicker)
        var title = NSLocalizedString("EditContacts.SaveDate", comment: "Caption for save date button")
        let ok = UIAlertAction(title: title, style: .default) { (action) in
            completion(datePicker.date)
        }
        alert.addAction(ok)
        if let currentDate = currentDate {
            datePicker.setDate(currentDate, animated: false)
            title = NSLocalizedString("EditContacts.RemoveDate", comment: "Caption for remove date button")
            let remove = UIAlertAction(title: title, style: .destructive) { (action) in
                completion(nil)
            }
            alert.addAction(remove)
        }
        title = NSLocalizedString("Common.Cancel", comment: "Caption for Cancel button")
        let cancel = UIAlertAction(title: title, style: .default, handler: nil)
        alert.addAction(cancel)
        rootVC.present(alert, animated: true, completion: nil)
    }
}

extension EditContactViewModel {
    func trailingSwipeActions(_ tableView: UITableView, indexPath: IndexPath)-> UISwipeActionsConfiguration? {
        guard (indexPath.section == 1 && indexPath.row < (contact.phones?.count ?? 0)) ||
        (indexPath.section == 2 && indexPath.row < (contact.emails?.count ?? 0)) ||
        (indexPath.section == 3 && indexPath.row < (contact.addresses?.count ?? 0))
            else { return UISwipeActionsConfiguration(actions: []) }
        let title = NSLocalizedString("EditContacts.DeleteCell", comment: "title for delete cell action")
        let act = UIContextualAction(style: .destructive, title: title) { [weak self] (action, view, completion) in
            guard let self = self else { return }
            switch indexPath.section {
            case 1:
                self.contact.phones?.remove(at: indexPath.row)
            case 2:
                self.contact.emails?.remove(at: indexPath.row)
            default:
                self.contact.addresses?.remove(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [act])
    }
    
    private func addElement(_ aboveIndexPath: IndexPath) {
        switch aboveIndexPath {
        case IndexPath(row: getNumberOfRows(section: 1) - 1, section: 1):
            let lbl = PhoneLabelString.next(byRawValue: contact.phones?.last?.label)
            let newPhone = LabelString(label: lbl, value: nil)
            guard let _ = contact.phones else {
                contact.phones = [newPhone]
                return
            }
            contact.phones?.append(newPhone)
        case IndexPath(row: getNumberOfRows(section: 2) - 1, section: 2):
            let lbl = EmailLabelString.next(byRawValue: contact.emails?.last?.label)
            let newEmail = LabelString(label: lbl, value: nil)
            guard let _ = contact.emails else {
                contact.emails = [newEmail]
                return
            }
            contact.emails?.append(newEmail)
        case IndexPath(row: getNumberOfRows(section: 3) - 1, section: 3):
            let lbl = AddressLabelString.next(byRawValue: contact.addresses?.last?.label)
            let currentCountry = Locale.current.regionCode
            let newAddress = LabelAddress(label: lbl, isoCountryCode: currentCountry, city: nil, street: nil, state: nil, postalCode: nil)
            guard let _ = contact.addresses else {
                contact.addresses = [newAddress]
                return
            }
            contact.addresses?.append(newAddress)
        default: break
        }
    }
    
    func saveButtonIsEnabled() -> Bool {
        guard !profileImageChanged else { return true }
        return clearedContact() != thisContactInStore
    }
    
    private func clearedContact() -> Contact? {
        var clearedContact = contact
        let clearedPhone = clearedContact.phones?.filter { $0.value != nil }
        let clearedEmail = clearedContact.emails?.filter { $0.value != nil }
        let clearedAddress = clearedContact.addresses?.filter { $0.isoCountryCode != nil && $0.city != nil }
        clearedContact.phones = clearedPhone?.count == 0 ? nil : clearedPhone
        clearedContact.emails = clearedEmail?.count == 0 ? nil : clearedEmail
        clearedContact.addresses = clearedAddress?.count == 0 ? nil : clearedAddress
        return clearedContact.isEmpty ? nil : clearedContact
    }
    
    func saveContact() {
        guard let clearedContact = self.clearedContact(),
        (clearedContact != thisContactInStore || profileImageChanged) else { return }
        HUDRenderer.showHUD()
        let userFbId = self.contactsProvider.userFacebookId
        var varContact = clearedContact
        guard let id = thisContactInStore?.id, id.count > 0 else {
            firebaseAgent.saveNewContact(userFbId: userFbId, contact: varContact, userProfileImage: profileImage)
            { [weak self] (error, contactID, imageUrl) in
                guard let self = self else { return }
                varContact.id = contactID
                self.updateAppStore(varContact, error: error, imageUrl: imageUrl)
            }
            return
        }
        if profileImageChanged && profileImage == nil {
            varContact.profileImage = nil
        }
        firebaseAgent.updateContact(userFbId: userFbId,
                                    contact: varContact, needSetNewImage: profileImageChanged,
                                    userProfileImage: profileImage) { [weak self] (error, imageUrl) in
                                        guard let self = self else { return }
                                        self.updateAppStore(varContact, error: error, imageUrl: imageUrl)
        }
    }
    
    private func updateAppStore(_ contact: Contact,error: String?,imageUrl: String?) {
        if let error = error {
            AlertHelper.showAlert(error)
            return
        }
        var varContact = contact
        if let imageUrl = imageUrl {
            varContact.profileImage = imageUrl
        }
        contactsProvider.updateContact(varContact)
        HUDRenderer.hideHUD()
        coordinator.backTaped()
    }
}
