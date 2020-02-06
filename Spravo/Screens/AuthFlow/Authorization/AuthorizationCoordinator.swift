//
//  AuthorizationCoordinator.swift
//  Spravo
//
//  Created by Onix on 9/27/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol AuthorizationCoordinatorTransitions: class {
    func startFetchPhoneContactsCoordinator(_ autoStartFetchContacts: Bool)
}

protocol AuthorizationCoordinatorType {
    func startFetchPhoneContactsCoordinator()
}

class AuthorizationCoordinator: AuthorizationCoordinatorType {
    private weak var navigationController: UINavigationController?
    private weak var controller = Storyboard.auth.controller(withClass: AuthorizationVC.self)
    private weak var transitions: AuthorizationCoordinatorTransitions?
    private var serviceHolder: ServiceHolder
    
    init(navigationController: UINavigationController?, transitions: AuthorizationCoordinatorTransitions, serviceHolder: ServiceHolder) {
        self.navigationController = navigationController
        self.transitions = transitions
        self.serviceHolder = serviceHolder
        controller?.viewModel = AuthorizationViewModel(self, serviceHolder: serviceHolder)
    }
    
    func start() {
        guard let controller = controller else { return }
        navigationController?.setViewControllers([controller], animated: false)
    }
    
    func startFetchPhoneContactsCoordinator() {
        transitions?.startFetchPhoneContactsCoordinator(false)
    }
}
