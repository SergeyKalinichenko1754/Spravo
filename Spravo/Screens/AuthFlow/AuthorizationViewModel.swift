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
    private var addressBook: AddressBookViewModel
    private var fbAuthorization: FBAuthorizationType
    private var firebaseAgent: FirebaseAgent
    
    init(_ coordinator: AuthorizationCoordinatorType, serviceHolder: ServiceHolder, addressBook: AddressBookViewModel) {
        self.coordinator = coordinator
        self.serviceHolder = serviceHolder
        self.addressBook = addressBook
        self.fbAuthorization = serviceHolder.get(by: FBAuthorization.self)
        self.firebaseAgent = serviceHolder.get(by: FirebaseAgent.self)
    }
    
    fileprivate func authWithFB(completion: @escaping (_ userID: String?) -> ()) {
        let currentVC = AlertHelper.getTopController(from: nil) //TODO(Serhii K) Transfer to VC
        fbAuthorization.fetchFacebookProfileId { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let userFbId):
                self.addressBook.userModel.userFacebookID = userFbId
                completion(userFbId)
            case .failure(let error):
                self.fbAuthorization.logOutFromFB()
                completion(nil)
                AlertHelper.showAlert(nil, msg: error, from: currentVC) //TODO(Serhii K) Transfer to VC
            }
        }
    }
    
    fileprivate func getFbUserName() {
        let currentVC = AlertHelper.getTopController(from: nil) //TODO(Serhii K) Transfer to VC
        fbAuthorization.fetchFacebookProfileName { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let userFbName):
                debugPrint("User name in FB : \(userFbName)")
                self.addressBook.userModel.userName = userFbName
                self.signIntoFirebase()
            case .failure(let error):
                if let error = error {
                    AlertHelper.showAlert(nil, msg: error, from: currentVC) //TODO(Serhii K) Transfer to VC
                }
            }
        }
    }
    
    fileprivate func signIntoFirebase() {
        let currentVC = AlertHelper.getTopController(from: nil) //TODO(Serhii K) Transfer to VC
        guard let token = fbAuthorization.getTokenString() else { return }
        firebaseAgent.signIntoFirebase(token: token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let providerID):
                debugPrint("Succesfully logged in Firebase with provider user ID: \(providerID)")
                self.fetchExistingContacts()
            case .failure(let error):
                if let error = error {
                    AlertHelper.showAlert(nil, msg: error, from: currentVC) //TODO(Serhii K) Transfer to VC
                }
            }
        }
    }
    
    fileprivate func fetchExistingContacts() {
    //TODO(SergeyK): Need modify function after development feching existing in Phone contacts
        firebaseAgent.getAllContacts(userFbId: addressBook.userFacebookID) { [weak self] (arr) in
            guard let self = self, let arr = arr else {
                debugPrint("Can't fetch addressBook from firebase store")
                return}
            self.addressBook.addressBookModel = arr
            debugPrint("Loaded \(arr.count) contacts from Firebase")
            self.coordinator.userDidLogin()
        }
    }
    
    func authWithFbAndGetUserName() {
        authWithFB(completion: { [weak self] (userFbId) in
            guard let self = self, let userFbId = userFbId else { return }
            debugPrint("Facebook user ID: \(userFbId)")
            self.getFbUserName()
        })
    }
    
    func logOut() {
        fbAuthorization.logOutFromFB()
    }
}
