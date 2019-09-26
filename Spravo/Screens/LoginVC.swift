//
//  LoginVC.swift
//  Spravo
//
//  Created by Onix on 9/26/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginVC: UIViewController, LoginButtonDelegate {
    
    @IBOutlet weak var facebookLoginButton: FBLoginButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    var viewModel: LoginViewModelType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.text = nil
        if let accessToken = AccessToken.current {
            logIn(accessToken.userID)
        }
        facebookLoginButton.delegate = self 
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            messageLabel.text = error.localizedDescription
            return
        }
        messageLabel.text = ""
        guard let result = result else { return }
        if result.isCancelled {
            messageLabel.text = NSLocalizedString("Login.Cancel.Warning", comment: "Message about the impossibility of entering the program without registering on Facebook")
            return
        } else if let accessToken = result.token {
            loginButton.isHidden = true
            logIn(accessToken.userID)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("User logged out")
    }
    
    func logIn(_ id: String) {
        //TODO(SerhiiK) Do login from ViewModel
        print("User logged with ID: \(id)")
    }
}
