//
//  FBAuthorization.swift
//  Spravo
//
//  Created by Onix on 9/27/19.
//  Copyright © 2019 Home. All rights reserved.
//

import FBSDKLoginKit

protocol FBAuthorizationType: Service {
    func getFBUserId() -> String?
    func getFBTokenExpDate() -> Date?
    func refreshToken()
    func fetchFacebookProfileId(completion: @escaping (Result<String, String?>) -> ())
    func fetchFacebookProfileName(completion: @escaping (Result<String, String?>) -> ())
    func logOutFromFB()
}

class FBAuthorization: FBAuthorizationType {
    let facebookPermissions = ["public_profile"]
    
    func getFBUserId() -> String? {
        guard let accessToken = AccessToken.current  else { return nil }
        return accessToken.userID
    }
    
    func getFBTokenExpDate() -> Date? {
        guard let accessToken = AccessToken.current  else { return nil }
        print("token updated: \(accessToken.refreshDate)")
        return accessToken.expirationDate
    }
    
    func refreshToken() {
        AccessToken.refreshCurrentAccessToken { (conection, result, error) in
            if error != nil {
                self.logOutFromFB()
                return
            }
            print("Token updated")
        }
    }
    
    func fetchFacebookProfileId(completion: @escaping (Result<String, String?>) -> ()) {
        if let userID = getFBUserId() {
            completion(.success(userID))
            return
        }
        LoginManager().logIn(permissions: facebookPermissions, from: nil) { (result, error) in
            if let error = error {
                completion(.failure(error.localizedDescription))
                return
            }
            guard let result = result else {
                completion(.failure(nil))
                return
            }
            if result.isCancelled {
                let message = NSLocalizedString("Login.Cancel.Warning", comment: "Message about the impossibility of entering the program without registering on Facebook")
                completion(.failure(message))
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
                    completion(.success(accessToken.userID))
                    return
                }
            }
            completion(.failure(nil))
        }
    }
    
    func fetchFacebookProfileName(completion: @escaping (Result<String, String?>) -> ()) {
        let parameters = ["fields": "first_name, last_name"]
        var name = ""
        GraphRequest(graphPath: "me", parameters: parameters).start { (connection, result, error) -> Void in
            if let error = error {
                completion(.failure(error.localizedDescription))
                return
            }
            if let responseDictionary = result as? NSDictionary {
                let firstNameFB = responseDictionary["first_name"] as? String
                let lastNameFB = responseDictionary["last_name"] as? String
                name = "\(firstNameFB ?? "") \(lastNameFB ?? "")"
            }
            completion(.success(name))
        }
    }
    
    func logOutFromFB() {
        LoginManager().logOut()
    }
    
    deinit {
        print("FBAuthorization deinit !!!")
    }
}
