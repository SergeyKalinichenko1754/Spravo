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
    
    func fetchFacebookProfileId(successBlock: @escaping (_ userID: String) -> (), failureBlock: @escaping (_ error: String?) -> ()) {
        if let userID = getFBUserId() {
            successBlock(userID)
            return
        }
        LoginManager().logIn(permissions: facebookPermissions, from: nil) { (result, error) in
            if let error = error {
                failureBlock(error.localizedDescription)
                return
            }
            guard let result = result else {
                failureBlock(nil)
                return
            }
            if result.isCancelled {
                let message = NSLocalizedString("Login.Cancel.Warning", comment: "Message about the impossibility of entering the program without registering on Facebook")
                failureBlock(message)
                return
            } else if let accessToken = result.token {
                var allPermsGranted = true
                let grantedPermissions = result.grantedPermissions
                for permission in self.facebookPermissions {
                    if !grantedPermissions.contains(permission) {
                        allPermsGranted = false
                        break
                    }
                }
                if allPermsGranted {
                    successBlock(accessToken.userID)
                    return
                }
            }
            failureBlock(nil)
        }
    }
    
    func logOutFromFB() {
        LoginManager().logOut()
    }
    
    func fetchFacebookProfileName(successBlock: @escaping (_ userName: String) -> (), failureBlock: @escaping (_ error: String?) -> ()) {
        let parameters = ["fields": "first_name, last_name"]
        var name = ""
        GraphRequest(graphPath: "me", parameters: parameters).start { (connection, result, error) -> Void in
            if let error = error {
                failureBlock(error.localizedDescription)
                return
            }
            if let responseDictionary = result as? NSDictionary {
                let firstNameFB = responseDictionary["first_name"] as? String
                let lastNameFB = responseDictionary["last_name"] as? String
                name = "\(firstNameFB ?? "") \(lastNameFB ?? "")"
            }
            successBlock(name)
        }
    }
}
