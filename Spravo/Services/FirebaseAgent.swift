//
//  FirebaseAgent.swift
//  Spravo
//
//  Created by Onix on 10/2/19.
//  Copyright © 2019 Home. All rights reserved.
//
import Firebase

protocol FirebaseAgentType: Service {
    func signIntoFirebase(token: String, completion: @escaping (Result<String, String?>) -> ())
    func getAllContacts(userFbId: String, completion: @escaping ((_ array: [Contact]?) -> ()))
    func saveNewContact(userFbId: String, contact: Contact, userProfileImage: UIImage?,
                        completion: @escaping (_ error: String?, _ documentID: String?, _ imageUrl: String?) -> ())
    func deleteContact(userFbId: String, contact: Contact, completion: @escaping (_ error: String?) -> ())
}

class FirebaseAgent: FirebaseAgentType {
    fileprivate let firestore = Firestore.firestore()
    fileprivate let storage = Storage.storage()
    fileprivate let prefixForUsersCollection = "user"
    fileprivate let prefixForUsersProfileImage = "profImageFor"
    
    func collectionExists(userFbId: String, completion: @escaping (_ result: BoolResult) -> ()) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.firestore.collection("\(self.prefixForUsersCollection)\(userFbId)").getDocuments() { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error.localizedDescription))
                } else {
                    if querySnapshot?.documents.count ?? 0 > 0 {
                        completion(.success(true))
                        return
                    }
                    completion(.success(false))
                }
            }
        }
    }
    
    func needAuthorization() -> Bool {
        return Auth.auth().currentUser != nil ? false : true
    }
    
    func signOut() -> Bool{
        do{
            try Auth.auth().signOut()
            return true
        }catch{
            return false
        }
    }
    
    func signIntoFirebase(token: String, completion: @escaping (Result<String, String?>) -> ()) {
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        Auth.auth().signIn(with: credential) { (result, error) in
            if let error = error {
                completion(.failure(error.localizedDescription))
                return
            } else if let result = result {
                completion(.success(result.user.uid))
                return
            }
            completion(.failure(nil))
        }
    }
    
    func getAllContacts(userFbId: String, completion: @escaping (_ array: [Contact]?) -> ()) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let decoder = JSONDecoder()
            var arr = [Contact]()
            self.firestore.collection("\(self.prefixForUsersCollection)\(userFbId)").getDocuments() { (querySnapshot, error) in
                if let _ = error {
                    completion(nil)
                } else {
                    for document in querySnapshot!.documents {
                        do {
                            let jsonData = try? JSONSerialization.data(withJSONObject: document.data())
                            let contact = try decoder.decode(Contact.self, from: jsonData!)
                            arr.append(contact)
                            arr[arr.count - 1].id = document.documentID
                            if arr[arr.count - 1].givenName?.count == 0 {
                                arr[arr.count - 1].givenName = nil
                            }
                        } catch let error  {
                            debugPrint(error.localizedDescription)
                        }
                    }
                    completion(arr)
                    return
                }
            }
        }
    }
    
    func saveNewContact(userFbId: String, contact: Contact, userProfileImage: UIImage? = nil,
                        completion: @escaping (_ error: String?, _ documentID: String?, _ imageUrl: String?) -> ()) {
        let syncingError = NSLocalizedString("ImportPhoneContacts.ErrorSyncingContactsFailed",
                                             comment: "Message about syncing contacts failed") + ": " + supportEmail
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let dict = contact.dictionary else {
                completion(syncingError, nil, nil)
                return
            }
            var ref: DocumentReference? = nil
            ref = self.firestore.collection("\(self.prefixForUsersCollection)\(userFbId)").addDocument(data: dict)
            { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    completion(error.localizedDescription, nil, nil)
                } else if let image = userProfileImage, let contactID = ref?.documentID {
                    self.uploadImage(userFbId: userFbId, contactID: contactID, image: image, completion: { imageUrl in
                        guard let imageUrl = imageUrl else {
                            completion(syncingError, contactID, nil)
                            return
                        }
                        completion(nil, contactID, imageUrl)
                    })
                } else {
                    completion(nil, ref?.documentID, nil)
                }
            }
        }
    }

    func updateContact(userFbId: String, contact: Contact, needSetNewImage: Bool, userProfileImage: UIImage? = nil,
                       completion: @escaping (_ error: String?, _ imageUrl: String?) -> ()) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let dict = contact.dictionary, let contactID = contact.id  else { return }
            let syncingError = NSLocalizedString("ImportPhoneContacts.ErrorSyncingContactsFailed",
                                                 comment: "Message about syncing contacts failed") + ": " + supportEmail
            if needSetNewImage && userProfileImage == nil {
                self.removeImageFromStorage(userFbId: userFbId, contactID: contactID, completion: { error in })
            }
            self.firestore.collection("\(self.prefixForUsersCollection)\(userFbId)").document(contactID).setData(dict, completion:
                { (error) in
                if let error = error {
                    completion(error.localizedDescription, nil)
                } else if needSetNewImage, let image = userProfileImage {
                    self.uploadImage(userFbId: userFbId, contactID: contactID, image: image, completion: { imageUrl in
                        guard let imageUrl = imageUrl else {
                            completion(syncingError, nil)
                            return
                        }
                        completion(nil, imageUrl)
                    })
                } else {
                    completion(nil, nil)
                }
            })
        }
    }
    
    func deleteContact(userFbId: String, contact: Contact, completion: @escaping (_ error: String?) -> ()) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let contactID = contact.id else { return }
            if let _ = contact.profileImage {
                self.removeImageFromStorage(userFbId: userFbId, contactID: contactID) { error in }
            }
            self.firestore.collection("\(self.prefixForUsersCollection)\(userFbId)").document(contactID).delete() { error in
                completion(error?.localizedDescription)
            }
        }
    }
    
    private func uploadImage(userFbId: String, contactID: String, image: UIImage, completion: @escaping (_ urlString: String?) -> ()) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let data = image.jpegData(compressionQuality: 1.0) else {
                completion(nil)
                return
            }
            let imageName = "\(self.prefixForUsersProfileImage)\(contactID)"
            let imageReference = self.storage.reference()
                .child("\(self.prefixForUsersCollection)\(userFbId)")
                .child(imageName)
            imageReference.putData(data, metadata: nil) { [weak self] (metadata, error) in
                guard let self = self, error == nil else {
                    completion(nil)
                    return
                }
                imageReference.downloadURL(completion: { [weak self] (url, error) in
                    guard let self = self, let urlString = url?.absoluteString, error == nil else {
                        completion(nil)
                        return
                    }
                    self.firestore.collection("\(self.prefixForUsersCollection)\(userFbId)").document(contactID).setData(["profileImage": urlString], merge: true, completion: { (error) in
                        if let _ = error {
                            completion(nil)
                            return
                        }
                        completion(urlString)
                    })
                })
            }
        }
    }
    
    private func removeImageFromStorage(userFbId: String, contactID: String, completion: @escaping (_ error: String?) -> ()) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let imageName = "\(self.prefixForUsersProfileImage)\(contactID)"
            let imageReference = self.storage.reference()
                .child("\(self.prefixForUsersCollection)\(userFbId)")
                .child(imageName)
            imageReference.delete { (error) in
                completion(error?.localizedDescription)
            }
        }
    }
}
