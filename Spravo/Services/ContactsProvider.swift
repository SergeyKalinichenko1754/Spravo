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
}

class ContactsProvider: ContactsProviderType {
    var user: User
    var contactModels: [Contact]
    
    init(user: User) {
        self.user = user
        self.contactModels = []
    }
    
    var userFacebookId: String {
        return user.facebookId ?? ""
    }
    
    var userName: String {
        return user.name ?? ""
    }
}
