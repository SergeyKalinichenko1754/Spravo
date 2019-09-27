//
//  FBAuthorization.swift
//  Spravo
//
//  Created by Onix on 9/27/19.
//  Copyright © 2019 Home. All rights reserved.
//

import FBSDKLoginKit

class FBAuthorization {
    let facebookPermissions = ["public_profile"]
    
    func getFBUserId() -> String? {
        guard let accessToken = AccessToken.current  else { return nil }
        return accessToken.userID
    }
    
    func loginToFB(successBlock: @escaping (_ userID: String) -> (), failureBlock: @escaping (_ error: String?) -> ()) {
        if let userID = getFBUserId() {
            successBlock(userID)
            return
        }
        LoginManager().logIn(permissions: facebookPermissions, from: nil) { (result, error) in
            if let error = error {
                //AlertHelper.showAlert(nil, msg: error.localizedDescription, from: self)
                failureBlock(error.localizedDescription)
                return
            }
            guard let result = result else {
                failureBlock(nil)
                return }
            
            if result.isCancelled {
                let message = NSLocalizedString("Login.Cancel.Warning", comment: "Message about the impossibility of entering the program without registering on Facebook")
                failureBlock(message)
                //AlertHelper.showAlert("⛔️", msg: message, from: self)
                return
            } else if let accessToken = result.token {
                var allPermsGranted = true
                let grantedPermissions = result.grantedPermissions.map( {"\($0)"} )
                for permission in self.facebookPermissions {
                    if !grantedPermissions.contains(permission) {
                        allPermsGranted = false
                        break
                    }
                }
                if allPermsGranted {
                    successBlock(accessToken.userID)
                    return
                    //                loginButton.isHidden = true
                    //                fetchFacebookProfile()
                    //                logIn(accessToken.userID)
                }
            }
            failureBlock(nil)
        }
    }
    
    func logOutFromFB() {
        LoginManager().logOut()
    }
    
    deinit {
        print("FBAuthorization ВСЕ !!!")
    }
    
}
