//
//  AuthorizationViewModel.swift
//  Spravo
//
//  Created by Onix on 9/25/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation
import UIKit

protocol AuthorizationViewModelType {
    func authWithFbAndGetUserName()
    func logOut()
}

class AuthorizationViewModel: AuthorizationViewModelType {
    fileprivate let coordinator: AuthorizationCoordinatorType
    private var serviceHolder: ServiceHolder
    
    init(_ coordinator: AuthorizationCoordinatorType, serviceHolder: ServiceHolder) {
        self.coordinator = coordinator
        self.serviceHolder = serviceHolder
    }
    
    func authWithFB(successBlock: @escaping (_ userID: String?) -> ()) {
        let currentVC = AlertHelper.getTopController(from: nil)
        FBAuthorization().fetchFacebookProfileId(successBlock: { (userFbId) in
            successBlock(userFbId)
            print("User Id : \(userFbId)")
        }) { (error) in
            if let error = error {
                FBAuthorization().logOutFromFB()
                successBlock(nil)
                AlertHelper.showAlert("⛔️", msg: error, from: currentVC)
            }
        }
    }
    
    func getFbUserName() {
        let currentVC = AlertHelper.getTopController(from: nil)
        FBAuthorization().fetchFacebookProfileName(successBlock: { (userFbName) in
            print("User name in FB : \(userFbName)")
        }) { (error) in
            if let error = error {
                AlertHelper.showAlert("⛔️", msg: error, from: currentVC)
            }
        }
    }
    
    func fetchExistingContacts() {
        let currentVC = AlertHelper.getTopController(from: nil)
        PhoneContactsAgent().fetchExistingContacts(successBlock: { (contacts) in
            guard let contacts = contacts else { return }
            print("Добыто контактов : \(contacts.count)")
        }) { (error) in
            if let error = error {
                AlertHelper.showAlert("⛔️", msg: error, from: currentVC)
            }
        }
    }
    
    func authWithFbAndGetUserName() {
        authWithFB(successBlock: { [weak self] (userFbId) in
            guard let self = self else { return }
            self.getFbUserName()
            self.fetchExistingContacts()
        })
    }
    
    func logOut() {
        FBAuthorization().logOutFromFB()
    }
}
