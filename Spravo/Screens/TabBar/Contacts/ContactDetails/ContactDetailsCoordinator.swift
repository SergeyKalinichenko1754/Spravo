//
//  ContactDetailsCoordinator.swift
//  Spravo
//
//  Created by Onix on 11/12/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol ContactDetailsCoordinatorTransitions: class {
}

protocol ContactDetailsCoordinatorType {
    func backTaped()
    func editContact(_ contact: Contact)
    func showContactOnMap(contact: Contact, addressNumber: Int)
}

class ContactDetailsCoordinator: ContactDetailsCoordinatorType {
    private let navigationController: UINavigationController?
    private weak var transitions: ContactDetailsCoordinatorTransitions?
    private weak var controller = Storyboard.contactDetails.controller(withClass: ContactDetailsVC.self)
    private var serviceHolder: ServiceHolder
    
    init(navigationController: UINavigationController?, transitions: ContactDetailsCoordinatorTransitions?, serviceHolder: ServiceHolder, contact: Contact) {
        self.navigationController = navigationController
        self.transitions = transitions
        self.serviceHolder = serviceHolder
        controller?.viewModel = ContactDetailsViewModel(coordinator: self, serviceHolder: serviceHolder, contact: contact)
    }
    
    func start() {
        guard let controller = controller else { return }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func backTaped() {
        controller?.navigationController?.popViewController(animated: true)
    }
}

extension ContactDetailsCoordinator: EditContactCoordinatorTransitions {
    func editContact(_ contact: Contact) {
        guard let navigation = navigationController else { return }
        let coordinator = EditContactCoordinator(navigationController: navigation, transitions: self, serviceHolder: serviceHolder, contact: contact)
        coordinator.start()
    }
}

extension ContactDetailsCoordinator: ContactOnMapCoordinatorTransitions {
    func showContactOnMap(contact: Contact, addressNumber: Int) {
        guard let navigation = navigationController else { return }
        let coordinator = ContactOnMapCoordinator(navigationController: navigation, transitions: self, serviceHolder: serviceHolder, contact: contact, addressNumber: addressNumber)
        coordinator.start()
    }
}
