//
//  LoginVC.swift
//  Spravo
//
//  Created by Onix on 9/24/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginVC: UIViewController, LoginButtonDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addFacebookButton()
        if let _ = AccessToken.current {
            print("User is already logged in")
            logIn()
        }
    }
    
    func addFacebookButton() {
        let logginButton = FBLoginButton()
        logginButton.delegate = self
        logginButton.center = view.center
        view.addSubview(logginButton)
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            assertionFailure(error.localizedDescription)
            return
        }
        if let _ = result?.token {
            loginButton.isHidden = true
            logIn()
        } else {
            exit(0)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        exit(0)
    }

    func logIn() {
        print("User logged in")
    }
}

