//
//  ContactDetailsViewModel.swift
//  Spravo
//
//  Created by Onix on 11/12/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

protocol ContactDetailsViewModelType {
    func fullName() -> String
}

class ContactDetailsViewModel: ContactDetailsViewModelType {
    private let coordinator : ContactDetailsCoordinatorType
    private var contact: Contact
    
    init(coordinator: ContactDetailsCoordinatorType, serviceHolder: ServiceHolder, contact: Contact) {
        self.coordinator = coordinator
        self.contact = contact
    }
    
    func fullName() -> String {
        return contact.fullName
    }
}
