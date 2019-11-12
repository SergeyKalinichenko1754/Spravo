//
//  PhoneContactsProvider.swift
//  Spravo
//
//  Created by Onix on 10/11/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Contacts

protocol PhoneContactsProviderType: Service {
    func requestAccess(completion: @escaping (BoolResult) -> Void)
    func fetchExistingPhoneContacts(completion: @escaping (_ result: BoolResult, _ contacts: [(Contact, Data?)]?) -> Void)
}

class PhoneContactsProvider: PhoneContactsProviderType {
    private let store = CNContactStore()
    
    func requestAccess(completion: @escaping (BoolResult) -> ()) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            completion(.success(true))
        case .restricted:
            completion(.success(false))
        case .denied:
            completion(.success(false))
        case .notDetermined:
            store.requestAccess(for: .contacts) { granted, error in
                if let error = error {
                    debugPrint(error)
                    completion(.failure(error.localizedDescription))
                    return
                } else if granted {
                    completion(.success(true))
                    return
                }
                completion(.success(false))
            }
        }
    }
    
    func fetchExistingPhoneContacts(completion: @escaping (_ result: BoolResult, _ contacts: [(Contact, Data?)]?) -> Void) {
        requestAccess { result in
            switch result {
            case .failure, .success(false):
                completion(result, nil)
            case .success(true):
                DispatchQueue.global().async {
                    var contactsArray = [(Contact, Data?)]()
                    let keys = [CNContactGivenNameKey, CNContactMiddleNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactPostalAddressesKey, CNContactImageDataKey, CNContactNoteKey]
                    let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                    do {
                        try self.store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerForStopEnumerating) in
                            let givenName = contact.givenName
                            let middleName = contact.middleName
                            let familyName = contact.familyName
                            let phones = contact.phoneNumbers.compactMap { LabelString(label: $0.label, value: $0.value.stringValue) }
                            let emails = contact.emailAddresses.compactMap { LabelString(label: $0.label, value: String($0.value)) }
                            let dob = contact.birthday?.date
                            let address = contact.postalAddresses.compactMap {LabelAddress(label: $0.label, isoCountryCode: $0.value.isoCountryCode, city: $0.value.city, street: $0.value.street, state: $0.value.state, postalCode: $0.value.postalCode)}
                            let image = contact.imageData
                            let note = contact.note
                            let addedContact = Contact(givenName: givenName,
                                                       middleName: middleName,
                                                       familyName: familyName,
                                                       phones: phones,
                                                       emails: emails,
                                                       birthday: dob,
                                                       addresses: address,
                                                       notes: note)
                            let contactProfile = (addedContact, image)
                            contactsArray.append(contactProfile)
                        })
                        DispatchQueue.main.async {
                            completion(.success(true), contactsArray)
                        }
                    } catch let error {
                        DispatchQueue.main.async {
                            completion(.failure(error.localizedDescription), nil)
                        }
                    }
                }
            }
        }
    }
}
