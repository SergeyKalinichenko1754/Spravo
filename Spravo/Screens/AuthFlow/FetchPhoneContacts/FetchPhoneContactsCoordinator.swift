//
//  FetchPhoneContactsCoordinator.swift
//  Spravo
//
//  Created by Onix on 10/10/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol FetcPhoneContactsCoordinatorTransitions: class {
    func userDidLogin()
}

protocol FetchPhoneContactsCoordinatorType {
    func userDidLogin()
}

class FetchPhoneContactsCoordinator: FetchPhoneContactsCoordinatorType {
    private weak var navigationController: UINavigationController?
    private weak var controller = Storyboard.auth.controller(withClass: FetchPhoneContactsVC.self)
    private weak var transitions: FetcPhoneContactsCoordinatorTransitions?
    private var serviceHolder: ServiceHolder
    
    init(navigationController: UINavigationController?, transitions: FetcPhoneContactsCoordinatorTransitions, serviceHolder: ServiceHolder) {
        self.navigationController = navigationController
        self.transitions = transitions
        self.serviceHolder = serviceHolder
        controller?.viewModel = FetcPhoneContactsViewModel(self, serviceHolder: serviceHolder)
    }
    
    func start() {
        guard let controller = controller else { return }
        navigationController?.pushViewController(controller, animated: true)
    }

    func userDidLogin() {
        transitions?.userDidLogin()
    }
}
