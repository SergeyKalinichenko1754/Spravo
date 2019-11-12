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
    func userInterruptedProgram()
}

protocol FetchPhoneContactsCoordinatorType {
    func userDidLogin()
    func userInterruptedProgram()
    var autoStartFetchContacts: Bool { get set }
}

class FetchPhoneContactsCoordinator: FetchPhoneContactsCoordinatorType {
    private weak var navigationController: UINavigationController?
    private weak var controller = Storyboard.auth.controller(withClass: FetchPhoneContactsVC.self)
    private weak var transitions: FetcPhoneContactsCoordinatorTransitions?
    private var serviceHolder: ServiceHolder
    var autoStartFetchContacts = false
    
    init(navigationController: UINavigationController?, transitions: FetcPhoneContactsCoordinatorTransitions, serviceHolder: ServiceHolder) {
        self.navigationController = navigationController
        self.transitions = transitions
        self.serviceHolder = serviceHolder
        controller?.viewModel = FetchPhoneContactsViewModel(self, serviceHolder: serviceHolder)
    }
    
    func start() {
        guard let controller = controller else { return }
        controller.autoStartFetchContacts = autoStartFetchContacts
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func userDidLogin() {
        transitions?.userDidLogin()
    }
    
    func userInterruptedProgram() {
        transitions?.userInterruptedProgram()
    }
}
