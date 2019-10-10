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
        rootNav.setNavigationBarHidden(true, animated: false)
        let fbAuthorization = serviceHolder.get(by: FBAuthorization.self),
        firebaseAgent = serviceHolder.get(by: FirebaseAgent.self)
        if !fbAuthorization.needAuthorization() && !firebaseAgent.needAuthorization() {
            //TODO(SergeyK): Revisit refresh token issue //fbAuthorization.refreshToken()
            startFetchPhoneContactsCoordinator()
            setupRootViewController(rootNav)
        } else {
            let coordinator = AuthorizationCoordinator(navigationController: rootNav, transitions: self, serviceHolder: serviceHolder)
            coordinator.start()
            setupRootViewController(rootNav)
        }
    }
    
    fileprivate func setupRootViewController(_ viewController: UIViewController) {
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
}

extension AuthFlowCoordinator: AuthorizationCoordinatorTransitions {
    func startFetchPhoneContactsCoordinator() {
        let coordinator = FetchPhoneContactsCoordinator(navigationController: rootNav, transitions: self, serviceHolder: serviceHolder)
        coordinator.start()
    }
}

extension AuthFlowCoordinator {
    private func startServices() {
        let fbAuthorization = FBAuthorization()
        let firebaseAgent = FirebaseAgent()
        let addressBookProvider = AddressBookProvider(user: UserModel())
        serviceHolder.add(FBAuthorization.self, for: fbAuthorization)
        serviceHolder.add(FirebaseAgent.self, for: firebaseAgent)
        serviceHolder.add(AddressBookProvider.self, for: addressBookProvider)
    }
    
    private func removeServices() {
        serviceHolder.remove(by: FBAuthorization.self)
        serviceHolder.remove(by: FirebaseAgent.self)
        serviceHolder.remove(by: AddressBookProvider.self)
    }
}

extension AuthFlowCoordinator: FetcPhoneContactsCoordinatorTransitions {
    func userDidLogin() {
        removeServices()
        transitions?.userDidLogin()
    }
}
