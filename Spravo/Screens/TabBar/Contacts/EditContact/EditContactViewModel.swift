//
//  EditContactViewModel.swift
//  Spravo
//
//  Created by Onix on 11/17/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

protocol EditContactViewModelType {
}

class EditContactViewModel: EditContactViewModelType {
    private let coordinator : EditContactCoordinatorType
    private var contact: Contact
    private var imageLoader: ImageLoader
    
    init(coordinator: EditContactCoordinatorType, serviceHolder: ServiceHolder, contact: Contact) {
        self.coordinator = coordinator
        self.contact = contact
        self.imageLoader = serviceHolder.get(by: ImageLoader.self)
    }
}
