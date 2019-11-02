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
    func syncingContacts(completion: @escaping (_ error: String?) -> Void)
    func userInterruptedAction()
}

class FetchPhoneContactsViewModel: FetchPhoneContactsViewModelType {
    fileprivate let coordinator: FetchPhoneContactsCoordinatorType
    private var serviceHolder: ServiceHolder
    private var contactsProvider: ContactsProvider
    private var phoneContactsProvider: PhoneContactsProvider
    private var firebaseAgent: FirebaseAgent
    private var phoneContacts: [(Contact, Data?)]?
    
    init(_ coordinator: FetchPhoneContactsCoordinatorType, serviceHolder: ServiceHolder) {
        self.coordinator = coordinator
        self.serviceHolder = serviceHolder
        self.contactsProvider = serviceHolder.get(by: ContactsProvider.self)
        self.phoneContactsProvider = serviceHolder.get(by: PhoneContactsProvider.self)
        self.firebaseAgent = serviceHolder.get(by: FirebaseAgent.self)
    }

    func fetchPhonesContacts(completion: @escaping (BoolResult) -> ()) {
        let error = NSLocalizedString("ImportPhoneContacts.ErrorFetchingPhoneContactsFailed", comment: "Message about fetching phones contacts failed") + ": " + supportEmail
        guard let userFbId = contactsProvider.user.facebookId else {
            completion(.failure(error))
            return
        }
        firebaseAgent.collectionExists(userFbId: userFbId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                completion(.failure(error))
            case .success(true):
                self.finishedRequestContacts()
            default:
                self.phoneContactsProvider.fetchExistingPhoneContacts { [weak self] (result, contacts) in
                    guard let self = self else { return }
                    switch result {
                    case .failure, .success(false):
                        completion(result)
                    case .success(true):
                        if let contacts = contacts {
                            self.phoneContacts = contacts
                            completion(result)
                        } else {
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
    }
    
    func syncingContacts(completion: @escaping (_ error: String?) -> Void) {
        guard let contacts = phoneContacts, let userFbId = contactsProvider.user.facebookId else {
            let error = NSLocalizedString("ImportPhoneContacts.ErrorSyncingContactsFailed", comment: "Message about syncing contacts failed") + ": " + supportEmail
            completion(error)
            return
        }
        var contactsQuantity = contacts.count
        for contact in contacts {
            var image: UIImage?
            if let data = contact.1 {
                image = UIImage(data: data)
            }
            firebaseAgent.saveNewContact(userFbId: userFbId, contact: contact.0, userProfileImage: image) { [weak self] error in
                guard let self = self else { return }
                contactsQuantity -= 1
                if error != nil {
                    self.phoneContacts = []
                    completion(error)
                    return
                } else if contactsQuantity == 0 {
                    self.phoneContacts = []
                    completion(nil)
                    return
                }
            }
        }
    }
    
    func finishedRequestContacts() {
        coordinator.userDidLogin()
    }
    
    func userInterruptedAction() {
        coordinator.userInterruptedProgram()
    }
}
