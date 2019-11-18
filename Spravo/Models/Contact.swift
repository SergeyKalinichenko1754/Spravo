//
//  AddressBookModel.swift
//  Spravo
//
//  Created by Onix on 10/3/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

enum PhoneLabelString: String {
    case home = "_$!<Home>!$_"
    case work = "_$!<Work>!$_"
    case iPhone = "_$!<iPhone>!$_"
    case mobile = "_$!<Mobile>!$_"
    case main = "_$!<Main>!$_"
    case homeFax = "_$!<HomeFAX>!$_"
    case workFax = "_$!<WorkFAX>!$_"
    case pager = "_$!<Pager>!$_"
    case other = "_$!<Other>!$_"
    case empty = "_$!<Empty>!$_"
}

enum EmailLabelString: String {
    case home = "_$!<Home>!$_"
    case work = "_$!<Work>!$_"
    case other = "_$!<Other>!$_"
    case empty = "_$!<Empty>!$_"
}

enum AddressLabelString: String {
    case home = "_$!<Home>!$_"
    case work = "_$!<Work>!$_"
    case other = "_$!<Other>!$_"
    case empty = "_$!<Empty>!$_"
}

/// Type that represents key / value pair for phone number or email and its type
struct LabelString: Codable {
    var label: String?
    var value: String?
    
    func phoneLbl() -> String {
        guard let lbl = self.label else { return "" }
        guard let _ = PhoneLabelString(rawValue: lbl) else { return lbl }
        return NSLocalizedString(lbl, comment: "Name phone Label")
    }

    func emailLbl() -> String {
        guard let lbl = self.label else { return "" }
        guard let _ = EmailLabelString(rawValue: lbl) else { return lbl }
        return NSLocalizedString(lbl, comment: "Name email Label")
    }
}

struct LabelAddress: Codable {
    var label: String?
    var isoCountryCode: String?
    var city: String?
    var street: String?
    var state: String?
    var postalCode: String?
    
    func addressLbl() -> String {
        guard let lbl = self.label else { return "" }
        guard let _ = AddressLabelString(rawValue: lbl) else { return lbl }
        return NSLocalizedString(lbl, comment: "Name address Label")
    }
    
    func address() -> String {
        var country = isoCountryCode
        if let isoCode = country {
            let locale = Locale.current
            country = locale.localizedString(forRegionCode: isoCode)
        }
        let address = [street, city, country].compactMap({$0})
        let lbl = address.joined(separator: ", ")
        return lbl 
    }
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
         phones: [LabelString]?,
         emails: [LabelString]?,
         birthday: Date? = nil,
         addresses: [LabelAddress]?,
         notes: String? = nil) {
        self.givenName = givenName
        self.middleName = middleName?.count == 0 ? nil : middleName
        self.familyName = familyName?.count == 0 ? nil : familyName
        self.phones = phones?.count == 0 ? nil : phones
        self.emails = emails?.count == 0 ? nil : emails
        self.birthday = birthday
        self.addresses = addresses?.count == 0 ? nil : addresses
        self.notes = notes?.count == 0 ? nil : notes
    }
}

extension Contact {
    var fullName: String {
        let fName = [givenName, middleName, familyName].compactMap({$0})
        if fName.count == 0 {
            return NSLocalizedString("Contacts.NoName", comment: "For contacts without any names")
        }
        return fName.joined(separator: " ")
    }
    
    var fullNamePrefix: String {
        let fName = [familyName, givenName, middleName].compactMap({$0})
        let name = fName.joined(separator: " ")
        return String((name.count == 0 ? "🕶" : name).prefix(1))
    }

    var lastNamePrefix: String {
        return String((familyName ?? "🕶").prefix(1))
    }

    var firstNamePrefix: String {
        return String((givenName ?? "🕶").prefix(1))
    }
    
    var fullNameStringForSort: String {
        let fName = [familyName, givenName, middleName].compactMap({$0})
        return fName.joined(separator: " ")
    }    
}
