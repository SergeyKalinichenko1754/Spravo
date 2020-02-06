//
//  AddressBookViewModel.swift
//  Spravo
//
//  Created by Onix on 10/4/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation
import Contacts

protocol ContactsProviderType: Service {
    var user: User { get }
    var contactModels: [Contact] { get }
    var userFacebookId: String { get }
    var userName: String { get }
    var contactsQuantity: Int { get }
    func logOut()
    func addFavourite(_ new: Favourite)
    func moveFavourite(from: Int, to: Int)
    func deleteFavourite(_ index: Int)
    func favouritesCount() -> Int
    func getFavourite(_ index: Int) -> Favourite?
    func isContactFavourite(id: String?, item: String) -> Bool
    func isContactFavourite(_ fav: Favourite) -> Bool
    func getContact(_ id: String?) -> Contact?
    func removeContact(_ id: String?)
    func updateContact(_ contact: Contact)
}

class ContactsProvider: ContactsProviderType {
    var user: User
    var contactModels: [Contact]
    private var favourites: [Favourite]
    private let keyForFavoriteStore = "FavoriteStore"
    private var recents: [Recent]
    private let keyForRecentStore = "RecentStore"
    
    init(user: User) {
        self.user = user
        self.contactModels = []
        self.favourites = []
        self.recents = []
        loadFavourites()
        loadRecents()
    }
    
    var userFacebookId: String {
        return user.facebookId ?? ""
    }
    
    var userName: String {
        return user.name ?? ""
    }
    
    var contactsQuantity: Int {
        return contactModels.count
    }
    
    func getContact(_ id: String?) -> Contact? {
        guard let id = id, let contact = contactModels.first(where: { $0.id == id }) else { return nil }
        return contact
    }
    
    func removeContact(_ id: String?) {
        guard let _ = id, let index = contactModels.firstIndex(where: { $0.id == id }) else { return }
        contactModels.remove(at: index)
    }
    
    func updateContact(_ contact: Contact) {
        guard let id = contact.id else { return }
        if let index = contactModels.firstIndex(where: { $0.id == id }) {
           contactModels[index] = contact
        } else {
           contactModels.append(contact)
        }
    }
    
    func getCNContact(_ contact: Contact) -> CNMutableContact {
        let sharedContact = CNMutableContact()
        sharedContact.givenName = contact.givenName ?? ""
        if let value = contact.middleName {
            sharedContact.middleName = value
        }
        if let value = contact.familyName {
            sharedContact.familyName = value
        }
        for phone in (contact.phones ?? [LabelString]()) {
            let label = phone.label == PhoneLabelString.empty.rawValue ? "" : phone.label
            sharedContact.phoneNumbers.append(CNLabeledValue(
                label: label, value: CNPhoneNumber(stringValue: phone.value ?? "")))
        }
        for email in (contact.emails ?? [LabelString]()) {
            let label = email.label == EmailLabelString.empty.rawValue ? "" : email.label
            sharedContact.emailAddresses.append(CNLabeledValue(
                label: label, value: (email.value ?? "") as NSString ))
        }
        for adr in (contact.addresses ?? [LabelAddress]()) {
            let label = adr.label == AddressLabelString.empty.rawValue ? "" : adr.label
            let address = getCNPostalAddress(adr)
            let oneMoreAddress = CNLabeledValue<CNPostalAddress>(label: label, value: address)
            sharedContact.postalAddresses.append(oneMoreAddress)
        }
        return sharedContact
    }
    
    func getCNPostalAddress(_ contactAddress: LabelAddress) -> CNMutablePostalAddress {
        let address = CNMutablePostalAddress()
        address.street = contactAddress.street ?? ""
        address.city = contactAddress.city ?? ""
        address.state = contactAddress.state ?? ""
        address.postalCode = contactAddress.postalCode ?? ""
        address.country = contactAddress.isoCountryCode ?? ""
        return address
    }
    
    func logOut() {
        user = User()
        contactModels = []
    }
}

extension ContactsProvider {
    func addFavourite(_ new: Favourite) {
        favourites.append(new)
        saveFavourite()
    }
    
    func moveFavourite(from: Int, to: Int) {
        let tempObj = favourites[from]
        favourites.remove(at: from)
        favourites.insert(tempObj, at: to)
        saveFavourite()
    }
    
    func deleteFavourite(_ index: Int) {
        favourites.remove(at: index)
        saveFavourite()
    }
    
    func favouritesCount() -> Int {
        return favourites.count
    }
    
    func getFavourite(_ index: Int) -> Favourite? {
        return index < favouritesCount() ? self.favourites[index] : nil
    }
    
    private func saveFavourite() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let data = self.favourites.map { try? JSONEncoder().encode($0) }
            UserDefaults.standard.set(data, forKey: self.keyForFavoriteStore)
        }
    }
    
    private func loadFavourites() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let encodedData = UserDefaults.standard.array(forKey: self.keyForFavoriteStore) as? [Data] else { return }
            self.favourites = encodedData.map { try! JSONDecoder().decode(Favourite.self, from: $0) }
        }
    }
    
    func isContactFavourite(id: String?, item: String) -> Bool {
        guard let _ = favourites.first(where: { $0.id == id && $0.favourite == item}) else { return false}
        return true
    }
    
    func isContactFavourite(_ fav: Favourite) -> Bool {
        guard let _ = favourites.first(where: {$0.id == fav.id && $0.type == fav.type && $0.favourite == fav.favourite}) else { return false}
        return true
    }
}

extension ContactsProvider {
    func addRecent(_ new: Recent) {
        recents.insert(new, at: 0)
        saveRecent()
    }
    
    func deleteRecent(_ index: Int) {
        recents.remove(at: index)
        saveRecent()
    }
    
    func recentsCount() -> Int {
        return recents.count
    }
    
    func getRecent(_ index: Int) -> Recent? {
        return index < recentsCount() ? self.recents[index] : nil
    }
    
    private func saveRecent() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let data = self.recents.map { try? JSONEncoder().encode($0) }
            UserDefaults.standard.set(data, forKey: self.keyForRecentStore)
        }
    }
    
    private func loadRecents() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let encodedData = UserDefaults.standard.array(forKey: self.keyForRecentStore) as? [Data] else { return }
            self.recents = encodedData.map { try! JSONDecoder().decode(Recent.self, from: $0) }
        }
    }
}
