//
//  AddressBookViewModel.swift
//  Spravo
//
//  Created by Onix on 10/4/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

protocol AddressBookProviderType: Service {
    var userModel: UserModel { get }
    var addressBookModel: [AddressBookModel] { get }
    var userFacebookID: String { get }
    var userName: String { get }
}

class AddressBookProvider: AddressBookProviderType {
    var userModel: UserModel
    var addressBookModel: [AddressBookModel]
    
    init(user: UserModel) {
        self.userModel = user
        self.addressBookModel = []
    }
    
    var userFacebookID: String {
        return userModel.userFacebookID ?? ""
    }
    
    var userName: String {
        return userModel.userName ?? ""
    }    
}
