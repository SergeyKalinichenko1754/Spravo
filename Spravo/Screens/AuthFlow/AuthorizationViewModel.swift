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
    private var fbAuthorization: FBAuthorizationType
    
    init(_ coordinator: AuthorizationCoordinatorType, serviceHolder: ServiceHolder) {
        self.coordinator = coordinator
        self.serviceHolder = serviceHolder
        self.fbAuthorization = serviceHolder.get(by: FBAuthorization.self)
    }
    
    func authWithFB(completion: @escaping (_ userID: String?) -> ()) {
        let currentVC = AlertHelper.getTopController(from: nil)
        fbAuthorization.fetchFacebookProfileId { result in
            switch result {
            case .success(let userFbId):
                completion(userFbId)
            case .failure(let error):
                FBAuthorization().logOutFromFB()
                completion(nil)
                AlertHelper.showAlert("⛔️", msg: error, from: currentVC)
            }
        }
    }
    
    func getFbUserName() {
        let currentVC = AlertHelper.getTopController(from: nil)
        fbAuthorization.fetchFacebookProfileName { [weak self]  result in
            guard let self = self else { return }
            switch result {
            case .success(let userFbName):
                print("User name in FB : \(userFbName)")
                self.coordinator.userDidLogin()
            case .failure(let error):
                if let error = error {
                    AlertHelper.showAlert("⛔️", msg: error, from: currentVC)
                }
            }
        }
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
