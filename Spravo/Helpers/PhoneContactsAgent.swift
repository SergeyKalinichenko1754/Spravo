//
//  PhoneContactsAgent.swift
//  Spravo
//
//  Created by Onix on 9/30/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Contacts

class PhoneContactsAgent {
    
    func fetchExistingContacts(successBlock: @escaping (_ contactsArr: [SpravoContact]?) -> (), failureBlock: @escaping (_ error: String?) -> ()) {
        print("TTRETRUYWTYRTWUYRTUWYTWTUY !!!!!!!")
        var issuesContacts = [SpravoContact]()
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                failureBlock(error.localizedDescription)
                print("Exit 0 !!!!!!!")
                return
            }
            if granted {
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactPostalAddressesKey, CNContactImageDataKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerForStopEnumerating) in
                        let givenName = contact.givenName
                        let familyName = contact.familyName
                        let phones = contact.phoneNumbers.compactMap { LabelString(label: $0.label, value: $0.value.stringValue) }
                        let emails = contact.emailAddresses.compactMap { LabelString(label: $0.label, value: String($0.value)) }
                        let dob = contact.birthday?.date
                        let address = contact.postalAddresses.compactMap {LabelAddress(label: $0.label, isoCountryCode: $0.value.isoCountryCode, city: $0.value.city, street: $0.value.street, state: $0.value.state, postalCode: $0.value.postalCode)}
                        let image = contact.imageData
                        let addedContact = SpravoContact(givenName: givenName,
                                                         familyName: familyName,
                                                         phones: phones,
                                                         emails: emails,
                                                         birthday: dob,
                                                         address: address,
                                                         image: image)
                        issuesContacts.append(addedContact)
                    })
                successBlock(issuesContacts)
                print("Exit ++++++++++ !!!!!!!")
                } catch let error {
                    failureBlock(error.localizedDescription)
                    print("Exit 1 !!!!!!!")
                    return
                }
            }
        }
    }
}
