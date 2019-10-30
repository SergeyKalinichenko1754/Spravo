//
//  ContactsViewModel.swift
//  Spravo
//
//  Created by Onix on 10/30/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

protocol ContactsViewModelType {
}

class ContactsViewModel: ContactsViewModelType {
    fileprivate let coordinator: ContactsCoordinatorType
    private var serviceHolder: ServiceHolder
    
    init(_ coordinator: ContactsCoordinatorType, serviceHolder: ServiceHolder) {
        self.coordinator = coordinator
        self.serviceHolder = serviceHolder
    }
}
