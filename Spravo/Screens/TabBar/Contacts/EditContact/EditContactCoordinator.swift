//
//  EditContactCoordinator.swift
//  Spravo
//
//  Created by Onix on 11/17/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol EditContactCoordinatorTransitions: class {
}

protocol EditContactCoordinatorType {
}

class EditContactCoordinator: EditContactCoordinatorType {
    private let navigationController: UINavigationController?
    private weak var transitions: EditContactCoordinatorTransitions?
    private weak var controller = Storyboard.contactDetails.controller(withClass: EditContactVC.self)
    private var serviceHolder: ServiceHolder
    
    init(navigationController: UINavigationController?, transitions: EditContactCoordinatorTransitions?, serviceHolder: ServiceHolder, contact: Contact) {
        self.navigationController = navigationController
        self.transitions = transitions
        self.serviceHolder = serviceHolder
        controller?.viewModel = EditContactViewModel(coordinator: self, serviceHolder: serviceHolder, contact: contact)
    }
    
    func start() {
        guard let controller = controller else { return }
        navigationController?.pushViewController(controller, animated: true)
    }

}
