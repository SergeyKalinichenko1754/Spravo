//
//  FetchPhoneContactsViewModel.swift
//  Spravo
//
//  Created by Onix on 10/10/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol FetchPhoneContactsViewModelType {
    func finishedRequestContacts()
    func fetchPhonesContacts(completion: @escaping (_ access: Bool) -> Void)
}

class FetchPhoneContactsViewModel: FetchPhoneContactsViewModelType {
    fileprivate let coordinator: FetchPhoneContactsCoordinatorType
    private var serviceHolder: ServiceHolder
    private var addressBookProvider: AddressBookProvider
    private var phoneContactsProvider: PhoneContactsProvider
    private var firebaseAgent: FirebaseAgent
    
    init(_ coordinator: FetchPhoneContactsCoordinatorType, serviceHolder: ServiceHolder) {
        self.coordinator = coordinator
        self.serviceHolder = serviceHolder
        self.addressBookProvider = serviceHolder.get(by: AddressBookProvider.self)
        self.phoneContactsProvider = serviceHolder.get(by: PhoneContactsProvider.self)
        self.firebaseAgent = serviceHolder.get(by: FirebaseAgent.self)
    }
    
    func fetchPhonesContacts(completion: @escaping (_ access: Bool) -> Void) {
        guard !phoneContactsProvider.isPhoneContactsLoadedAlready() else {
            completion(true)
            return
        }
        phoneContactsProvider.requestAccess { [weak self] (result) in
            guard let self = self else { return }
            if !result {
                completion(false)
                return
            }
            self.finishedRequestContacts()
        }
    }
    
    func finishedRequestContacts() {
        coordinator.userDidLogin()
    }
        
}
