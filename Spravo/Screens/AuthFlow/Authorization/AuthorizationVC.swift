//
//  AuthorizationVC.swift
//  Spravo
//
//  Created by Onix on 9/26/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class AuthorizationVC: UIViewController {
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    var viewModel: AuthorizationViewModelType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeScreen()
    }
    
    fileprivate func localizeScreen() {
        messageLabel.text = NSLocalizedString("Login.WelcomeTo", comment: "Welcome to")
        let loginBtnCaption = NSLocalizedString("Login.LoginButtonCaption", comment: "Caption of Login with facebook button")
        facebookLoginButton.setTitle(loginBtnCaption, for: .normal)
    }
        
    @IBAction func tapedLoginWithFBButton(_ sender: UIButton) {
        viewModel.authWithFbAndGetUserName() { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                AlertHelper.showAlert(nil, msg: error, from: self)
                return
            }
            self.facebookLoginButton.isHidden = true
        }
    }
}
