//
//  PhoneContactsProvider.swift
//  Spravo
//
//  Created by Onix on 10/11/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Contacts

protocol PhoneContactsProviderType: Service {
    func isPhoneContactsLoadedAlready() -> Bool
    func requestAccess(completion: @escaping (_ accessGranted: Bool) -> Void)
    func fetchExistingPhoneContacts(completion: @escaping (_ access: Bool) -> Void)
}

class PhoneContactsProvider: PhoneContactsProviderType {
    private let store = CNContactStore()
    private var contactLoadedAlreadyKey: String {
        return "DateOfUplodePhoneContactsToFBForUser"
    }
    
    func isPhoneContactsLoadedAlready() -> Bool {
        guard let _ = UserDefaults.standard.object(forKey: contactLoadedAlreadyKey) as? Date else { return false }
        return true
    }
    
    func requestAccess(completion: @escaping (_ accessGranted: Bool) -> Void) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            fetchExistingPhoneContacts { access in
                if access {
                    completion(true)
                    return
                }
                completion(false)
            }
        case .restricted:
            completion(false)
        case .denied:
            completion(false)
        case .notDetermined:
            store.requestAccess(for: .contacts) { [weak self] granted, error in
                guard let self = self else {
                    completion(false)
                    return}
                if let error = error {
                    debugPrint(error)
                    completion(false)
                    return
                } else if granted {
                    self.fetchExistingPhoneContacts { access in
                        if access {
                            completion(true)
                            return
                        }
                        completion(false)
                    }
                    return
                }
                completion(false)
            }
        }
    }
    
    func fetchExistingPhoneContacts(completion: @escaping (_ access: Bool) -> Void) {
        completion(true)
        return
    }
    
}
