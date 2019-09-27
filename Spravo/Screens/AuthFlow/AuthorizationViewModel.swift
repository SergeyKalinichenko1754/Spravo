//
//  AuthorizationViewModel.swift
//  Spravo
//
//  Created by Onix on 9/25/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

protocol AuthorizationViewModelType {
    func fetchIssueContacts()
}

class AuthorizationViewModel: AuthorizationViewModelType {
  
    func fetchIssueContacts() {
        print("fetch Contacts")
    }
}

