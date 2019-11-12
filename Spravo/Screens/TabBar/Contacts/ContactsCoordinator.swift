//
//  ContactsCoordinator.swift
//  Spravo
//
//  Created by Onix on 10/30/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol ContactsCoordinatorTransitions: class {
    func startFetchPhoneContacts()
}

protocol ContactsCoordinatorType {
    func startFetchPhoneContacts()
    func showContactDetails(_ contact: Contact)
}

class ContactsCoordinator: ContactsCoordinatorType {
    private weak var navigationController: UINavigationController?
    private weak var transitions: ContactsCoordinatorTransitions?
    private weak var controller = Storyboard.contacts.controller(withClass: ContactsVC.self)
    private var serviceHolder: ServiceHolder
    
    init(navigationController: UINavigationController?, transitions: ContactsCoordinatorTransitions?, serviceHolder: ServiceHolder) {
        self.navigationController = navigationController
        self.transitions = transitions
        self.serviceHolder = serviceHolder
        controller?.viewModel = ContactsViewModel(self, serviceHolder: serviceHolder)
    }
    
    func start() {
        if let controller = controller {
            navigationController?.setViewControllers([controller], animated: true)
        }
    }
    
    func startFetchPhoneContacts() {
        transitions?.startFetchPhoneContacts()
    }
}

extension ContactsCoordinator: ContactDetailsCoordinatorTransitions {
    func showContactDetails(_ contact: Contact) {
        guard let navigation = navigationController else { return }
        let coordinator = ContactDetailsCoordinator(navigationController: navigation, transitions: self, serviceHolder: serviceHolder, contact: contact)
        coordinator.start()
    }
}
