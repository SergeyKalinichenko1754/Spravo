//
//  AuthorizationVC.swift
//  Spravo
//
//  Created by Onix on 9/26/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class AuthorizationVC: UIViewController {
    @IBOutlet weak var facebookLoginButton: FBLoginButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    
    var viewModel: AuthorizationViewModelType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeScreen()
    }
    
    func localizeScreen() {
        messageLabel.text = viewModel.greeting()
        let loginBtnCaption = NSLocalizedString("Login.LoginButtonCaption", comment: "Caption of Login with facebook button")
        facebookLoginButton.setTitle(loginBtnCaption, for: .normal)
    }
    
    func showActualButtuns() {
        facebookLoginButton.isHidden = !facebookLoginButton.isHidden
        logOutButton.isHidden = !logOutButton.isHidden
    }
    
    @IBAction func tapedLoginWithFBButton(_ sender: UIButton) {
        viewModel.authWithFbAndGetUserName()
        showActualButtuns()
        //messageLabel.text = userFbName + "\n" + viewModel.greeting()
    }
    
    @IBAction func tapedLogOutButton(_ sender: UIButton) {
        viewModel.logOut()
        showActualButtuns()
        print("User logged out")
    }
}
