//
//  AuthorizationViewModel.swift
//  Spravo
//
//  Created by Onix on 9/25/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol AuthorizationViewModelType {
    func authWithFbAndGetUserName()
    func logOut()
}

class AuthorizationViewModel: AuthorizationViewModelType {
    fileprivate let coordinator: AuthorizationCoordinatorType
    private var serviceHolder: ServiceHolder
    private var fbAuthorization: FBAuthorizationType
    private var firebaseAgent: FirebaseAgent
    
    private var userFbId = ""
    
    init(_ coordinator: AuthorizationCoordinatorType, serviceHolder: ServiceHolder) {
        self.coordinator = coordinator
        self.serviceHolder = serviceHolder
        self.fbAuthorization = serviceHolder.get(by: FBAuthorization.self)
        self.firebaseAgent = serviceHolder.get(by: FirebaseAgent.self)
    }
    
    fileprivate func authWithFB(completion: @escaping (_ userID: String?) -> ()) {
        let currentVC = AlertHelper.getTopController(from: nil)
        fbAuthorization.fetchFacebookProfileId { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let userFbId):
                self.userFbId = userFbId
                completion(userFbId)
            case .failure(let error):
                self.fbAuthorization.logOutFromFB()
                completion(nil)
                AlertHelper.showAlert(nil, msg: error, from: currentVC)
            }
        }
    }
    
    fileprivate func getFbUserName() {
        let currentVC = AlertHelper.getTopController(from: nil)
        fbAuthorization.fetchFacebookProfileName { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let userFbName):
                print("User name in FB : \(userFbName)")
                self.signIntoFirebase()
            case .failure(let error):
                if let error = error {
                    AlertHelper.showAlert(nil, msg: error, from: currentVC)
                }
            }
        }
    }
    
    fileprivate func signIntoFirebase() {
        let currentVC = AlertHelper.getTopController(from: nil)
        guard let token = fbAuthorization.getTokenString() else { return }
        firebaseAgent.signIntoFirebase(token: token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let providerID):
                print("Succesfully logged with provider ID: \(providerID)")
                self.fetchExistingContacts()
            case .failure(let error):
                if let error = error {
                    AlertHelper.showAlert("⛔️", msg: error, from: currentVC)
                }
            }
        }
    }
    
    fileprivate func fetchExistingContacts() {
        
        firebaseAgent.getContacts(at: self.userFbId) { (arr) in
            
            print(arr)
        }
        
        
        firebaseAgent.save(userFbId: self.userFbId)
        coordinator.userDidLogin()
    }
    
    func authWithFbAndGetUserName() {
        authWithFB(completion: { [weak self] (userFbId) in
            guard let self = self, let userFbId = userFbId else { return }
            print("Facebook user ID: \(userFbId)")
            self.getFbUserName()
        })
    }
    
    func logOut() {
        fbAuthorization.logOutFromFB()
    }
}
