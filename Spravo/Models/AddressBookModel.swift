//
//  AddressBookModel.swift
//  Spravo
//
//  Created by Onix on 10/3/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

/// Type that represents key / value pair for phone number or email and its type
struct LabelString: Codable {
    var label: String?
    var value: String?
}

struct LabelAddress: Codable {
    var label: String?
    var isoCountryCode: String?
    var city: String?
    var street: String?
    var state: String?
    var postalCode: String?
}

struct AddressBookModel: Codable {
    var id: String?
    var givenName: String?
    var familyName: String?
    var phones: [LabelString]?
    var emails: [LabelString]?
    var birthday: Date?
    var addresses: [LabelAddress]?
    var notes: String?
    var profileImage: String?
}

extension AddressBookModel {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        guard let rawJson = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let json = rawJson as? [String: Any] else {
                debugPrint("Cannot convert SpravoContact")
                return nil
        }
        return json
    }
}

extension AddressBookModel {
    init(givenName: String,
         familyName: String? = nil,
         phones: [LabelString] = [],
         emails: [LabelString] = [],
         birthday: Date? = nil,
         addresses: [LabelAddress] = [],
         notes: String? = nil,
         profileImage: String? = nil) {
        self.givenName = givenName
        self.familyName = familyName
        self.phones = phones
        self.emails = emails
        self.birthday = birthday
        self.addresses = addresses
        self.notes = notes
    }
}
