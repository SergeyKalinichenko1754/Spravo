//
//  ModelSpravo.swift
//  Spravo
//
//  Created by Onix on 9/24/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

//struct AddressBook: Codable {
//    let name: String?
//    let phoneNumber: String?
//    let birthday: Date?
//}

struct SpravoContact: Codable {
    let givenName: String?
    let familyName: String?
    let phones: [LabelString]?
    let emails: [LabelString]?
    let birthday: Date?
    let address: [LabelAddress]?
    let image: Data?
}

struct LabelString: Codable {
    let label: String?
    let value: String?
}

struct LabelAddress: Codable {
    let label: String?
    let isoCountryCode: String?
    let city: String?
    let street: String?
    let state: String?
    let postalCode: String?
}
