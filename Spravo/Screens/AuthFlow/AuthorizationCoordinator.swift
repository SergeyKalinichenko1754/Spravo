//
//  AuthorizationCoordinator.swift
//  Spravo
//
//  Created by Onix on 9/27/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol AuthorizationCoordinatorTransitions: class {
    func userDidLogin()
}

protocol AuthorizationCoordinatorType {
    func userDidLogin()
}

class AuthorizationCoordinator: AuthorizationCoordinatorType {
    private weak var navigationController: UINavigationController?
    private weak var controller = Storyboard.auth.controller(withClass: AuthorizationVC.self)
    private weak var transitions: AuthorizationCoordinatorTransitions?
    private var serviceHolder: ServiceHolder
    
    init(navigationController: UINavigationController?, transitions: AuthorizationCoordinatorTransitions, serviceHolder: ServiceHolder, addressBookProvider: AddressBookProvider) {
        self.navigationController = navigationController
        self.transitions = transitions
        self.serviceHolder = serviceHolder
        controller?.viewModel = AuthorizationViewModel(self, serviceHolder: serviceHolder, addressBookProvider: addressBookProvider)
    }
    
    func start() {
        guard let controller = controller else { return }
        navigationController?.setViewControllers([controller], animated: false)
    }
    
    func userDidLogin() {
        transitions?.userDidLogin()
    }
}
