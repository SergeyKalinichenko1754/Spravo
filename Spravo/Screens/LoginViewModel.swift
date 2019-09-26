//
//  LoginViewModel.swift
//  Spravo
//
//  Created by Onix on 9/25/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

protocol LoginViewModelType {
    func fetchIssueContacts()
}

class LoginViewModel: LoginViewModelType {
  
    func fetchIssueContacts() {
        print("fetch Contacts")
    }
}

