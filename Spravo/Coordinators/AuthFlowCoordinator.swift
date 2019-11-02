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
    func userInterruptedProgram()
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
        let fbAuthorization = serviceHolder.get(by: FBAuthorization.self),
        firebaseAgent = serviceHolder.get(by: FirebaseAgent.self),
        contactsProvider = serviceHolder.get(by: ContactsProvider.self)
        if !fbAuthorization.needAuthorization() && !firebaseAgent.needAuthorization() {
            //TODO(SergeyK): Revisit refresh token issue //fbAuthorization.refreshToken()
            guard let userFbId = fbAuthorization.getFBUserId() else { return }
            contactsProvider.user.facebookId = userFbId
            transitions?.userDidLogin()
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
        let phoneContactsProvider = PhoneContactsProvider()
        serviceHolder.add(PhoneContactsProvider.self, for: phoneContactsProvider)
        let coordinator = FetchPhoneContactsCoordinator(navigationController: rootNav, transitions: self, serviceHolder: serviceHolder)
        coordinator.start()
    }
}

extension AuthFlowCoordinator: FetcPhoneContactsCoordinatorTransitions {
    func userDidLogin() {
        transitions?.userDidLogin()
    }
    
    func userInterruptedProgram() {
        transitions?.userInterruptedProgram()
    }
}
