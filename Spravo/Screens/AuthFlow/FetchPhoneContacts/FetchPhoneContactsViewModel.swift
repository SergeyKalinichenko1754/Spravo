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
    func userInterruptedAction()
}

class FetchPhoneContactsViewModel: FetchPhoneContactsViewModelType {
    fileprivate let coordinator: FetchPhoneContactsCoordinatorType
    private var serviceHolder: ServiceHolder
    private var addressBookProvider: ContactsProvider
    private var phoneContactsProvider: PhoneContactsProvider
    private var firebaseAgent: FirebaseAgent
    
    init(_ coordinator: FetchPhoneContactsCoordinatorType, serviceHolder: ServiceHolder) {
        self.coordinator = coordinator
        self.serviceHolder = serviceHolder
        self.addressBookProvider = serviceHolder.get(by: ContactsProvider.self)
        self.phoneContactsProvider = serviceHolder.get(by: PhoneContactsProvider.self)
        self.firebaseAgent = serviceHolder.get(by: FirebaseAgent.self)
    }
    
    func fetchPhonesContacts(completion: @escaping (_ access: Bool) -> Void) {
        guard let userFbId = addressBookProvider.userModel.facebookId,
            !phoneContactsProvider.isPhoneContactsLoadedAlready(userFbId: userFbId) else {
            completion(true)
            return
        }
        phoneContactsProvider.requestAccess { [weak self] (result) in
            guard let _ = self else { return }
            if !result {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func syncingContacts(completion: @escaping (_ access: Bool) -> Void) {
        //TODO(Serhii K.) will remove in next stage (realizing fetch phones contacts)
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(2)) { [weak self] in
            guard let _ = self else { return }
            completion(true)
        }
    }
    
    func finishedRequestContacts() {
        coordinator.userDidLogin()
    }
    
    func userInterruptedAction() {
        coordinator.userInterruptedProgram()
    }
}
