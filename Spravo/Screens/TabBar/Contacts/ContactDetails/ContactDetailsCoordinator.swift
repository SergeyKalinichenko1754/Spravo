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
}
