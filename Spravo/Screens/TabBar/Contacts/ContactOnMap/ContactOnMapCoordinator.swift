//
//  ContactOnMapCoordinator.swift
//  Spravo
//
//  Created by Onix on 11/18/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol ContactOnMapCoordinatorTransitions: class {
}

protocol ContactOnMapCoordinatorType {
    func backTaped()
}

class ContactOnMapCoordinator: ContactOnMapCoordinatorType {
    private weak var navigationController: UINavigationController?
    private weak var transitions: ContactOnMapCoordinatorTransitions?
    private weak var controller = Storyboard.contactDetails.controller(withClass: ContactOnMapVC.self)
    private var serviceHolder: ServiceHolder
    
    init(navigationController: UINavigationController?, transitions: ContactOnMapCoordinatorTransitions?, serviceHolder: ServiceHolder, contact: Contact, addressNumber: Int) {
        self.navigationController = navigationController
        self.transitions = transitions
        self.serviceHolder = serviceHolder
        controller?.viewModel = ContactOnMapViewModel(coordinator: self, serviceHolder: serviceHolder, contact: contact, addressNumber: addressNumber)
    }
    
    func start() {
        guard let controller = controller else { return }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func backTaped() {
        controller?.navigationController?.popViewController(animated: true)
    }
}
