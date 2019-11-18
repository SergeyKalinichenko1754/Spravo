//
//  AppCoordinator.swift
//  Spravo
//
//  Created by Onix on 9/27/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class AppCoordinator {
    private let window: UIWindow
    private let serviceHolder = ServiceHolder()
    private var authFlowCoordinator: AuthFlowCoordinator?
    private var tabBarCoordinator: TabBarCoordinator?
    
    init(window: UIWindow) {
        self.window = window
        start()
    }
    
    private func start() {
        startInitialServices()
        authorizationStart()
    }
    
    private func authorizationStart() {
        tabBarCoordinator = nil
        authFlowCoordinator = AuthFlowCoordinator(window: window, transitions: self, serviceHolder: serviceHolder)
        authFlowCoordinator?.start()
    }
    
    private func enterApp() {
        authFlowCoordinator = nil
        tabBarCoordinator = TabBarCoordinator(window: window, transitions: self, serviceHolder: serviceHolder)
        tabBarCoordinator?.start()
    }
}

extension AppCoordinator {
    private func startInitialServices() {
        let fbAuthorization = FBAuthorization()
        let firebaseAgent = FirebaseAgent()
        let contactsProvider = ContactsProvider(user: User())
        let imageLoader = ImageLoader()
        serviceHolder.add(FBAuthorization.self, for: fbAuthorization)
        serviceHolder.add(FirebaseAgent.self, for: firebaseAgent)
        serviceHolder.add(ContactsProvider.self, for: contactsProvider)
        serviceHolder.add(ImageLoader.self, for: imageLoader)
    }
}

extension AppCoordinator: AuthFlowCoordinatorTransitions {
    func userDidLogin() {
        enterApp()
    }
    
    func userInterruptedProgram() {
        //TODO(Serhii K.) will be change later
        exit(0)
    }
}

extension AppCoordinator: TabBarCoordinatorTransitions {
    func logout() {
        let fbAuthorization = serviceHolder.get(by: FBAuthorization.self),
        firebaseAgent = serviceHolder.get(by: FirebaseAgent.self),
        contactsProvider = serviceHolder.get(by: ContactsProvider.self),
        _ = firebaseAgent.signOut()
        fbAuthorization.logOutFromFB()
        contactsProvider.logOut()
        authorizationStart()
    }
    
    func startFetchPhoneContacts() {
        tabBarCoordinator = nil
        authFlowCoordinator = AuthFlowCoordinator(window: window, transitions: self, serviceHolder: serviceHolder)
        authFlowCoordinator?.startFromFetch()
    }
}
