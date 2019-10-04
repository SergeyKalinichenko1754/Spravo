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
    
    func deleteContact(userFbId: String, contactID: String)
    
}

class FirebaseAgent: FirebaseAgentType {
    
    let firestore = Firestore.firestore()
    
    func signIntoFirebase(token: String, completion: @escaping (Result<String, String?>) -> ()) {
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        Auth.auth().signIn(with: credential) { (result, error) in
            if let error = error {
                completion(.failure(error.localizedDescription))
                return
            } else if let result = result {
                completion(.success(result.user.providerID))
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
    
    func deleteContact(userFbId: String, contactID: String) {
        firestore.collection("user\(userFbId)").document(contactID).delete() { error in
            if let error = error {
                debugPrint("Error removing document: \(error)")
            } else {
                debugPrint("Document \(contactID) successfully removed!")
            }
        }
    }
    
    deinit {
        debugPrint("FirebaseAgent deinit !!!")
    }
}
