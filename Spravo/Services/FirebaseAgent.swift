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
    func saveNewContact(userFbId: String, contact: Contact, userProfileImage: UIImage?, completion: @escaping (_ error: String?) -> ())
    func deleteContact(userFbId: String, contact: Contact)
    func uploadImage(userFbId: String, contactID: String, image: UIImage, completion: @escaping (_ urlString: String?) -> ())
}

class FirebaseAgent: FirebaseAgentType {
    fileprivate let firestore = Firestore.firestore()
    fileprivate let storage = Storage.storage()
    fileprivate let prefixForUsersCollection = "user"
    fileprivate let prefixForUsersProfileImage = "profImageFor"
    
    func collectionExists(userFbId: String, completion: @escaping (_ result: BoolResult) -> ()) {
        firestore.collection("\(prefixForUsersCollection)\(userFbId)").getDocuments() { (querySnapshot, error) in
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
    
    func needAuthorization() -> Bool {
        if let _ = Auth.auth().currentUser {
            return false
        }
        return true
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
        let decoder = JSONDecoder()
        var arr = [Contact]()
        firestore.collection("\(prefixForUsersCollection)\(userFbId)").getDocuments() { (querySnapshot, err) in
            if let err = err {
                debugPrint("Error getting documents: \(err)")
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
    
    func saveNewContact(userFbId: String, contact: Contact, userProfileImage: UIImage? = nil, completion: @escaping (_ error: String?) -> ()) {
        DispatchQueue.global().async { [weak self] in
            let syncingError = NSLocalizedString("ImportPhoneContacts.ErrorSyncingContactsFailed", comment: "Message about syncing contacts failed") + ": " + supportEmail
            guard let self = self else {
                DispatchQueue.main.async {
                    completion(syncingError)
                }
                return
            }
            var ref: DocumentReference? = nil
            guard let dict = contact.dictionary else {
                DispatchQueue.main.async {
                    completion(syncingError)
                }
                return }
            ref = self.firestore.collection("\(self.prefixForUsersCollection)\(userFbId)").addDocument(data: dict)
            { [weak self] error in
                guard let self = self else {
                    DispatchQueue.main.async {
                        completion(syncingError)
                    }
                    return
                }
                if let error = error {
                    DispatchQueue.main.async {
                        completion(error.localizedDescription)
                    }
                } else if let image = userProfileImage, let contactID = ref?.documentID {
                    self.uploadImage(userFbId: userFbId, contactID: contactID, image: image, completion: { imageUrl in
                        guard let _ = imageUrl else {
                            DispatchQueue.main.async {
                                completion(syncingError)
                            }
                            return
                        }
                    })
                    
                }
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }

    func updateContact(userFbId: String, contact: Contact) {
        guard let dict = contact.dictionary, let contactId = contact.id  else { return }
        firestore.collection("\(prefixForUsersCollection)\(userFbId)").document(contactId).setData(dict, completion: { (error) in
            if let error = error {
                debugPrint("Error updating document: \(error)")
            } else {
                debugPrint("Document \(contactId) successfully updated")
            }
        })
    }
    
    func deleteContact(userFbId: String, contact: Contact) {
        guard let contactID = contact.id else { return }
        if let _ = contact.profileImage {
           removeImageFromStorage(userFbId: userFbId, contactID: contactID)
        }
        firestore.collection("\(prefixForUsersCollection)\(userFbId)").document(contactID).delete() { error in
            if let error = error {
                debugPrint("Error removing document: \(error)")
            } else {
                debugPrint("Document \(contactID) successfully removed!")
            }
        }
    }
    
    func uploadImage(userFbId: String, contactID: String, image: UIImage, completion: @escaping (_ urlString: String?) -> ()) {
        guard let data = image.jpegData(compressionQuality: 1.0) else {
            debugPrint("Problem with convertation image to data for contact \(contactID)")
            completion(nil)
            return}
        let imageName = "\(prefixForUsersProfileImage)\(contactID)"
        let imageReference = storage.reference()
            .child("\(prefixForUsersCollection)\(userFbId)")
            .child(imageName)
        imageReference.putData(data, metadata: nil) { [weak self] (metadata, error) in
            guard let self = self else {
                completion(nil)
                return }
            if let error = error {
                debugPrint("Problem with upload image for contact \(contactID): \(error.localizedDescription)")
                completion(nil)
                return
            }
            imageReference.downloadURL(completion: { [weak self] (url, error) in
                guard let self = self else {
                    completion(nil)
                    return }
                if let error = error {
                    debugPrint("Problem with upload image for contact \(contactID): \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                guard let urlString = url?.absoluteString else {
                    debugPrint("Problem with get image url for contact \(contactID)")
                    completion(nil)
                    return
                }
                self.firestore.collection("\(self.prefixForUsersCollection)\(userFbId)").document(contactID).setData(["profileImage": urlString], merge: true, completion: { (error) in
                    if let error = error {
                        debugPrint("Problem with upload Url image for contact \(contactID): \(error.localizedDescription)")
                        completion(nil)
                        return
                    }
                    completion(urlString)
                })
            })
        }
    }
    
    func removeImageFromStorage(userFbId: String, contactID: String) {
        let imageName = "\(prefixForUsersProfileImage)\(contactID)"
        let imageReference = storage.reference()
            .child("\(prefixForUsersCollection)\(userFbId)")
            .child(imageName)
        imageReference.delete { (error) in
            if let error = error {
                debugPrint("Problem with deleting image from storage for contact \(contactID): \(error.localizedDescription)")
            }
        }
    }
}
