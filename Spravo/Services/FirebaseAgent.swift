//
//  FirebaseAgent.swift
//  Spravo
//
//  Created by Onix on 10/2/19.
//  Copyright © 2019 Home. All rights reserved.
//
import Firebase


struct SpravoContact: Codable {
    let id: String
    let givenName: String?
    let familyName: String?
    let phones: [LabelString]?
    
    init?(aDoc: DocumentSnapshot) {
        self.id = aDoc.documentID
        self.givenName = aDoc.get("givenName") as? String
        self.familyName = aDoc.get("familyName") as? String
        self.phones = aDoc.get("phones") as? [LabelString]
    }
    
    
//    init?(_ dictionary: [String : Any]) {
//        self.givenName = dictionary["givenName"] as? String
//        self.familyName = dictionary["familyName"] as? String
//        //self.phones = dictionary["phones"] as? [LabelString]
//        let dphones = dictionary["phones"] as? [String : Any]
//        if let label = dphones?["label"] as? String,
//            let value = dphones?["value"] as? String {
//            let phone = LabelString(label: label, value: value)
//            self.phones = [phone]
//        } else {
//            self.phones = nil
//        }
//    }
 }

struct LabelString: Codable {
    let label: String
    let value: String
}

protocol FirebaseAgentType: Service {
    func save(userFbId: String)
    func signIntoFirebase(token: String, completion: @escaping (Result<String, String?>) -> ())
    
    func getContacts(at userFbId: String, completion: @escaping (([SpravoContact]) -> ()))
    
}

class FirebaseAgent: FirebaseAgentType {
    
    func save(userFbId: String) {
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        ref = db.collection("user\(userFbId)").addDocument(data: [
            "givenName": "Vasia",
            "familyName": "Pupkin",
            "phones": [
                [
                    "label": "home",
                    "value": "+380991234567"
                ],
                [
                    "label": "work",
                    "value": "+380503554211"
                ],
                [
                    "label": "main",
                    "value": "+3806655555555"
                ]
            ]
            ])
        { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    func getContacts(at userFbId: String, completion: @escaping (([SpravoContact]) -> ())) {
        let data = Firestore.firestore().collection("user\(userFbId)")
        data.getDocuments { (snapshot, error) in
            if let error = error {
                print("ERROR In Loading !!!!!!!!!!: \(error)")
                completion([])
                return
            }
            let addresses = snapshot?.documents.compactMap({SpravoContact(aDoc: $0)}) ?? []
            completion(addresses)
        }
    }
    
    deinit {
        print("FirebaseAgent deinit !!!")
    }
    
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
}
