//
//  AuthorizationVC.swift
//  Spravo
//
//  Created by Onix on 9/26/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class AuthorizationVC: UIViewController, LoginButtonDelegate {
    
    @IBOutlet weak var facebookLoginButton: FBLoginButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    var viewModel: AuthorizationViewModelType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeScreen()
        if let accessToken = AccessToken.current {
            fetchFacebookProfile()
            logIn(accessToken.userID)
        }
        facebookLoginButton.delegate = self 
    }
    
    func localizeScreen() {
        messageLabel.text = NSLocalizedString("Login.WelcomeTo", comment: "Welcome to")
    }
    
    

    
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            AlertHelper.showAlert(nil, msg: error.localizedDescription, from: self)
            messageLabel.text = error.localizedDescription
            return
        }
        localizeScreen()
        guard let result = result else { return }
        if result.isCancelled {
            let message = NSLocalizedString("Login.Cancel.Warning", comment: "Message about the impossibility of entering the program without registering on Facebook")
            AlertHelper.showAlert("⛔️", msg: message, from: self)
            return
        } else if let accessToken = result.token {
            loginButton.isHidden = true
            fetchFacebookProfile()
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
    
    func fetchFacebookProfile() {
        let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
        GraphRequest(graphPath: "me", parameters: parameters).start { (connection, result, error) -> Void in
            if let error = error {
                AlertHelper.showAlert(nil, msg: error.localizedDescription, from: self)
                return
            }
            if let responseDictionary = result as? NSDictionary {
                let firstNameFB = responseDictionary["first_name"] as? String
                let lastNameFB = responseDictionary["last_name"] as? String
                self.messageLabel.text = "\(firstNameFB ?? "") \(lastNameFB ?? "")\n" + NSLocalizedString("Login.WelcomeTo", comment: "Welcome to")
// TODO(SerhiiK) implement later if will be need show users image
//                var pictureUrl = ""
//                if let picture = responseDictionary["picture"] as? NSDictionary, let data = picture["data"] as? NSDictionary, let url = data["url"] as? String {
//                    pictureUrl = url
//                    print(pictureUrl)
//                }
            }
        }
    }
    
    
    @IBAction func tapedMyFBBtn(_ sender: UIButton) {
        viewModel.authWithFB()
    }
    
    
}
