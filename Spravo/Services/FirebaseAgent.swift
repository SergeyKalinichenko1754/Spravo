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
    func getAllContacts(userFbId: String, completion: @escaping ((_ array: [AddressBookModel]?) -> ()))
    func saveNewContact(userFbId: String, contact: AddressBookModel)
    func deleteContact(userFbId: String, contact: AddressBookModel)
    func uploadImage(userFbId: String, contactID: String, image: UIImage, completion: @escaping (_ urlString: String?) -> ())
}

class FirebaseAgent: FirebaseAgentType {
    fileprivate let firestore = Firestore.firestore()
    fileprivate let storage = Storage.storage()
    
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
    
    func getAllContacts(userFbId: String, completion: @escaping (_ array: [AddressBookModel]?) -> ()) {
        let decoder = JSONDecoder()
        var arr = [AddressBookModel]()
        firestore.collection("user\(userFbId)").getDocuments() { (querySnapshot, err) in
            if let err = err {
                debugPrint("Error getting documents: \(err)")
                completion(nil)
            } else {
                for document in querySnapshot!.documents {
                    do {
                        let jsonData = try? JSONSerialization.data(withJSONObject: document.data())
                        let contact = try decoder.decode(AddressBookModel.self, from: jsonData!)
                        arr.append(contact)
                        arr[arr.count - 1].id = document.documentID
                    } catch let error  {
                        print(error.localizedDescription)
                    }
                }
                completion(arr)
                return
            }
        }
    }
    
    func saveNewContact(userFbId: String, contact: AddressBookModel) {
        var ref: DocumentReference? = nil
        guard let dict = contact.dictionary else { return }
        ref = firestore.collection("user\(userFbId)").addDocument(data: dict)
        { error in
            if let error = error {
                debugPrint("Error adding document: \(error)")
            } else {
                debugPrint("Document added with ID: \(ref!.documentID)")
            }
        }
    }

    func updateContact(userFbId: String, contact: AddressBookModel) {
        guard let dict = contact.dictionary, let contactID = contact.id  else { return }
        firestore.collection("user\(userFbId)").document(contactID).setData(dict, completion: { (error) in
            if let error = error {
                debugPrint("Error updating document: \(error)")
            } else {
                debugPrint("Document \(contactID) successfully updated")
            }
        })
    }
    
    func deleteContact(userFbId: String, contact: AddressBookModel) {
        guard let contactID = contact.id else { return }
        if let _ = contact.profileImage {
           removeImageFromStorage(userFbId: userFbId, contactID: contactID)
        }
        firestore.collection("user\(userFbId)").document(contactID).delete() { error in
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
        let imageName = "profImageFor\(contactID)"
        let imageReference = storage.reference()
            .child("user\(userFbId)")
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
            imageReference.downloadURL(completion: { (url, error) in
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
                self.firestore.collection("user\(userFbId)").document(contactID).setData(["profileImage": urlString], merge: true, completion: { (error) in
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
        let imageName = "profImageFor\(contactID)"
        let imageReference = storage.reference()
            .child("user\(userFbId)")
            .child(imageName)
        imageReference.delete { (error) in
            if let error = error {
                debugPrint("Problem with deleting image from storage for contact \(contactID): \(error.localizedDescription)")
            }
        }
    }
        
    deinit {
        debugPrint("FirebaseAgent deinit !!!")
    }
}
