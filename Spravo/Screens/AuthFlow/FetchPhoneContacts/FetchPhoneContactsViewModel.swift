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
    func fetchPhonesContacts(completion: @escaping (BoolResult) -> Void)
    func syncingContacts(completion: @escaping (_ access: Bool) -> Void)
    func userInterruptedAction()
}

class FetchPhoneContactsViewModel: FetchPhoneContactsViewModelType {
    fileprivate let coordinator: FetchPhoneContactsCoordinatorType
    private var serviceHolder: ServiceHolder
    private var addressBookProvider: ContactsProvider
    private var phoneContactsProvider: PhoneContactsProvider
    private var firebaseAgent: FirebaseAgent
    private var phoneContacts: [(Contact, Data?)]?
    
    init(_ coordinator: FetchPhoneContactsCoordinatorType, serviceHolder: ServiceHolder) {
        self.coordinator = coordinator
        self.serviceHolder = serviceHolder
        self.addressBookProvider = serviceHolder.get(by: ContactsProvider.self)
        self.phoneContactsProvider = serviceHolder.get(by: PhoneContactsProvider.self)
        self.firebaseAgent = serviceHolder.get(by: FirebaseAgent.self)
    }

    func fetchPhonesContacts(completion: @escaping (BoolResult) -> ()) {
        guard let userFbId = addressBookProvider.userModel.facebookId,
            !phoneContactsProvider.isPhoneContactsLoadedAlready(userFbId: userFbId) else {
            completion(.failure("Phone contacts allready uploded"))
            return
        }
        //TODO(Serhii K.) question to Seniour ( Should implement [weak self]? )
        phoneContactsProvider.fetchExistingPhoneContacts { (result, contacts) in
            switch result {
            case .failure, .success(false):
                completion(result)
            case .success(true):
                if let contacts = contacts {
                    self.phoneContacts = contacts
                    completion(result)
                } else {
                    let error = NSLocalizedString("ImportPhoneContacts.ErrorFetchingPhoneContactsFailed", comment: "Message about fetching phones contacts failed") + ": " + supportEmail
                    completion(.failure(error))
                }
            }
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
