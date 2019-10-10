//
//  FetchPhoneContactsViewModel.swift
//  Spravo
//
//  Created by Onix on 10/10/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol FetchPhoneContactsViewModelType {
    
}

class FetcPhoneContactsViewModel: FetchPhoneContactsViewModelType {
    fileprivate let coordinator: FetchPhoneContactsCoordinatorType
    private var serviceHolder: ServiceHolder
    private var addressBookProvider: AddressBookProvider
    private var firebaseAgent: FirebaseAgent
    
    init(_ coordinator: FetchPhoneContactsCoordinatorType, serviceHolder: ServiceHolder) {
        self.coordinator = coordinator
        self.serviceHolder = serviceHolder
        self.addressBookProvider = serviceHolder.get(by: AddressBookProvider.self)
        self.firebaseAgent = serviceHolder.get(by: FirebaseAgent.self)
    }
    
    fileprivate func fetchExistingContacts() {
        //TODO(SergeyK): Need modify function after development feching existing in Phone contacts
        firebaseAgent.getAllContacts(userFbId: addressBookProvider.userFacebookID) { [weak self] (arr) in
            guard let self = self, let arr = arr else {
                debugPrint("Can't fetch addressBook from firebase store")
                return}
            self.addressBookProvider.addressBookModel = arr
            debugPrint("Loaded \(arr.count) contacts from Firebase")
            HUDRenderer.hideHUD()
            self.coordinator.userDidLogin()
        }
    }
}
