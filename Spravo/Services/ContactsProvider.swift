//
//  AddressBookViewModel.swift
//  Spravo
//
//  Created by Onix on 10/4/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

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
    
    init(user: User) {
        self.user = user
        self.contactModels = []
        self.favourites = []
        loadFavourite()
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
    
    func logOut() {
        user = User()
        contactModels = []
    }
    
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
    
    private func loadFavourite() {
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
