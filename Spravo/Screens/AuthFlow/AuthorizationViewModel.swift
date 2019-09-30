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
    func greeting() -> String
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
    
    func greeting() -> String {
        return NSLocalizedString("Login.WelcomeTo", comment: "Welcome to")
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
    
    func authWithFbAndGetUserName() {
        authWithFB(successBlock: { (userFbId) in
            self.getFbUserName()
        })
    }
    
    func logOut() {
        FBAuthorization().logOutFromFB()
    }
}
