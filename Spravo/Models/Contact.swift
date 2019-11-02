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

struct Contact: Codable {
    var id: String?
    var givenName: String?
    var middleName: String?
    var familyName: String?
    var phones: [LabelString]?
    var emails: [LabelString]?
    var birthday: Date?
    var addresses: [LabelAddress]?
    var notes: String?
    var profileImage: String?
}

extension Contact {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        guard let rowJson = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let json = rowJson as? [String: Any] else {
                debugPrint("Cannot convert SpravoContact")
                return nil
        }
        return json
    }
}

extension Contact {
    init(givenName: String,
         middleName: String? = nil,
         familyName: String? = nil,
         phones: [LabelString] = [],
         emails: [LabelString] = [],
         birthday: Date? = nil,
         addresses: [LabelAddress] = [],
         notes: String? = nil,
         profileImage: String? = nil) {
        self.givenName = givenName
        self.middleName = middleName
        self.familyName = familyName
        self.phones = phones
        self.emails = emails
        self.birthday = birthday
        self.addresses = addresses
        self.notes = notes
    }
}

extension Contact {
    var fullName: String {
        let fName = [givenName, middleName, familyName].compactMap({$0})
        return fName.joined(separator: " ")
    }
    
    var namePrefix: String {
        let fName = [familyName, givenName, middleName].compactMap({$0})
        let name = fName.joined(separator: " ")
        return String((name.count == 0 ? "#" : name).prefix(1))
    }
}
