//
//  ProfileCoordinator.swift
//  Spravo
//
//  Created by Onix on 10/30/19.
//  Copyright © 2019 Home. All rights reserved.
//


import UIKit

protocol ProfileCoordinatorTransitions: class {
}

protocol ProfileCoordinatorType: class {
}

class ProfileCoordinator: ProfileCoordinatorType {
    private weak var navigationController: UINavigationController?
    private weak var transitions: ProfileCoordinatorTransitions?
    private weak var controller = Storyboard.profile.controller(withClass: ProfileVC.self)
    private var serviceHolder: ServiceHolder
    
    init(navigationController: UINavigationController?, transitions: ProfileCoordinatorTransitions, serviceHolder: ServiceHolder) {
        self.navigationController = navigationController
        self.transitions = transitions
        self.serviceHolder = serviceHolder
        controller?.viewModel = ProfileViewModel(self, serviceHolder: serviceHolder)
    }
    
    func start() {
        if let controller = controller {
            navigationController?.setViewControllers([controller], animated: true)
        }
    }
}
