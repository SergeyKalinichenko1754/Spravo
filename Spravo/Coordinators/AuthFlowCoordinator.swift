//
//  AuthFlowCoordinator.swift
//  Spravo
//
//  Created by Onix on 9/27/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol AuthFlowCoordinatorTransitions: class {
    func userDidLogin()
  
}

class AuthFlowCoordinator {
    
    private let window: UIWindow
    private let rootNav = UINavigationController()
    private weak var transitions: AuthFlowCoordinatorTransitions?
    private var serviceHolder: ServiceHolder
    
    init(window: UIWindow, transitions: AuthFlowCoordinatorTransitions, serviceHolder: ServiceHolder) {
        self.window = window
        self.transitions = transitions
        self.serviceHolder = serviceHolder
    }
    
    func start() {
        rootNav.setNavigationBarHidden(true, animated: false)
        let coordinator = AuthorizationCoordinator(navigationController: rootNav, transitions: self, serviceHolder: serviceHolder)
        coordinator.start()
        window.rootViewController = rootNav
        window.makeKeyAndVisible()
    }
}

extension AuthFlowCoordinator: AuthorizationCoordinatorTransitions {
    func userDidLogin() {
        transitions?.userDidLogin()
    }
}
