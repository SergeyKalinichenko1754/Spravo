//
//  AuthorizationViewModel.swift
//  Spravo
//
//  Created by Onix on 9/25/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol AuthorizationViewModelType {
    func authWithFbAndGetUserName(completion: @escaping (String?) -> ())
    func logOut()
}

class AuthorizationViewModel: AuthorizationViewModelType {
    fileprivate let coordinator: AuthorizationCoordinatorType
    private var serviceHolder: ServiceHolder
    private var contactsProvider: ContactsProvider
    private var fbAuthorization: FBAuthorizationType
    private var firebaseAgent: FirebaseAgent
    
    init(_ coordinator: AuthorizationCoordinatorType, serviceHolder: ServiceHolder) {
        self.coordinator = coordinator
        self.serviceHolder = serviceHolder
        self.contactsProvider = serviceHolder.get(by: ContactsProvider.self)
        self.fbAuthorization = serviceHolder.get(by: FBAuthorization.self)
        self.firebaseAgent = serviceHolder.get(by: FirebaseAgent.self)
    }
    
    fileprivate func authWithFB(completion: @escaping (Result<String, String?>) -> ()) {
        fbAuthorization.fetchFacebookProfileId { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let userFbId):
                self.contactsProvider.user.facebookId = userFbId
                completion(.success(userFbId))
            case .failure(let error):
                self.fbAuthorization.logOutFromFB()
                completion(.failure(error))
            }
        }
    }
    
    fileprivate func getFbUserName() {
        fbAuthorization.fetchFacebookProfileName { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let userFbName):
                debugPrint("User name in FB : \(userFbName)")
                self.contactsProvider.user.name = userFbName
            case .failure(let error):
                if let error = error {
                    debugPrint("Error : \(error)")
                }
            }
        }
    }
    
    fileprivate func signIntoFirebase(completion: @escaping (Result<String, String?>) -> ()) {
        guard let token = fbAuthorization.getTokenString() else { return }
        firebaseAgent.signIntoFirebase(token: token) { result in
            switch result {
            case .success(let providerID):
                completion(.success(providerID))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func authWithFbAndGetUserName(completion: @escaping (String?) -> ()) {
        authWithFB(completion: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let userFbId):
                debugPrint("Facebook user ID: \(userFbId)")
                self.getFbUserName()
                self.signIntoFirebase(completion: { [weak self] (result) in
                    guard let self = self else { return }
                    switch result {
                    case .success(let providerID):
                        debugPrint("Succesfully logged in Firebase with provider user ID: \(providerID)")
                        self.coordinator.startFetchPhoneContactsCoordinator()
                    case .failure(let error):
                        completion(error)
                    }
                })
            case .failure(let error):
                completion(error)
            }
        })
    }
    
    func logOut() {
        fbAuthorization.logOutFromFB()
    }
}
