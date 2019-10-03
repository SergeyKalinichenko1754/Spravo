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
        startServices()
        let fbAuthorization = serviceHolder.get(by: FBAuthorization.self)
        //TODO(SergeyK): Temporary log Out form Fb on start (need for setting authorization). After setting should delete !
        fbAuthorization.logOutFromFB()
        if !fbAuthorization.needAuthorization() {
            //TODO(SergeyK): Revisit refresh token issue //fbAuthorization.refreshToken()
            userDidLogin()
        } else {
            rootNav.setNavigationBarHidden(true, animated: false)
            let coordinator = AuthorizationCoordinator(navigationController: rootNav, transitions: self, serviceHolder: serviceHolder)
            coordinator.start()
            window.rootViewController = rootNav
            window.makeKeyAndVisible()
        }
    }
}

extension AuthFlowCoordinator: AuthorizationCoordinatorTransitions {
    func userDidLogin() {
        removeServices()
        transitions?.userDidLogin()
    }
}

extension AuthFlowCoordinator {
    private func startServices() {
        let fbAuthorization = FBAuthorization()
        serviceHolder.add(FBAuthorization.self, for: fbAuthorization)
    }
    
    private func removeServices() {
        serviceHolder.remove(by: FBAuthorization.self)
    }
}
