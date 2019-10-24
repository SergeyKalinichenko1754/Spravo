//
//  AddressBookViewModel.swift
//  Spravo
//
//  Created by Onix on 10/4/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

protocol ContactsProviderType: Service {
    var userModel: User { get }
    var contactsModel: [Contact] { get }
    var userFacebookId: String { get }
    var userName: String { get }
}

class ContactsProvider: ContactsProviderType {
    var userModel: User
    var contactsModel: [Contact]
    
    init(user: User) {
        self.userModel = user
        self.contactsModel = []
    }
    
    var userFacebookId: String {
        return userModel.facebookId ?? ""
    }
    
    var userName: String {
        return userModel.name ?? ""
    }
}
