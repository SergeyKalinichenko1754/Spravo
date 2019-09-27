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
    
    func fetchIssueContacts()
    func authWithFB()
    
}

class AuthorizationViewModel: AuthorizationViewModelType {
    fileprivate let coordinator: AuthorizationCoordinatorType
    private var serviceHolder: ServiceHolder
    
    init(_ coordinator: AuthorizationCoordinatorType, serviceHolder: ServiceHolder) {
        self.coordinator = coordinator
        self.serviceHolder = serviceHolder
    }
    
    
    func authWithFB() {
        FBAuthorization().loginToFB(successBlock: { (id) in
            print("success Block return userID: \(id)")
        }) { (error) in
            if let error = error {
                print("Failure block return error: \(error)")
                
                AlertHelper.showAlert("⛔️", msg: error)
                
                
            }
        }
    }
  
    func fetchIssueContacts() {
        print("fetch Contacts")
    }
}

