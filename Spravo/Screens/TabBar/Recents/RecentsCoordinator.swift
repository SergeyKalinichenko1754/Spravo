//
//  RecentsCoordinator.swift
//  Spravo
//
//  Created by Onix on 10/30/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol RecentsCoordinatorTransitions: class {
}

protocol RecentsCoordinatorType {
    func showContactDetails(_ contact: Contact)
}

class RecentsCoordinator: RecentsCoordinatorType {
    private weak var navigationController: UINavigationController?
    private weak var transitions: RecentsCoordinatorTransitions?
    private weak var controller = Storyboard.recents.controller(withClass: RecentsVC.self)
    private var serviceHolder: ServiceHolder
    
    init(navigationController: UINavigationController?, transitions: RecentsCoordinatorTransitions?, serviceHolder: ServiceHolder) {
        self.navigationController = navigationController
        self.transitions = transitions
        self.serviceHolder = serviceHolder
        controller?.viewModel = RecentsViewModel(self, serviceHolder: serviceHolder)
    }
    
    func start() {
        if let controller = controller {
            navigationController?.setViewControllers([controller], animated: true)
        }
    }
}

extension RecentsCoordinator: ContactDetailsCoordinatorTransitions {
    func showContactDetails(_ contact: Contact) {
        guard let navigation = navigationController else { return }
        let coordinator = ContactDetailsCoordinator(navigationController: navigation, transitions: self, serviceHolder: serviceHolder, contact: contact)
        coordinator.start()
    }
}
