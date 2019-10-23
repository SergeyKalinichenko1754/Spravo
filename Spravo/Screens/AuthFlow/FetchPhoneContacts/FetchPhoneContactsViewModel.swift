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
    func syncingContacts(completion: @escaping (_ access: Bool) -> Void)
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
        guard let userFbId = addressBookProvider.userModel.userFacebookID,
            !phoneContactsProvider.isPhoneContactsLoadedAlready(userFbId: userFbId) else {
            completion(true)
            return
        }
        phoneContactsProvider.requestAccess { [weak self] (result) in
            guard let self = self else { return }
            if !result {
                completion(false)
                return
            }
            self.coordinator.startActivityScreen(labels: ["Reading contacts", "Syncing with Spravo"])
            //TODO(Serhii K.) Timer wirr remove in next stage (realizing fetch phones cntacts)
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (timer) in
                completion(true)
            })
            
        }
    }
    
    func syncingContacts(completion: @escaping (_ access: Bool) -> Void) {
        coordinator.starNextActivityIndicator()
        //TODO(Serhii K.) Timer wirr remove in next stage (realizing fetch phones cntacts)
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { [weak self] timer in
            guard let self = self else { return }
            self.coordinator.starNextActivityIndicator()
            completion(true)
        })
    }
    
    func finishedRequestContacts() {
        coordinator.userDidLogin()
    }
}
