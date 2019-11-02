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
        authFlowCoordinator = AuthFlowCoordinator(window: window, transitions: self, serviceHolder: serviceHolder)
        authFlowCoordinator?.start()
        tabBarCoordinator = nil
    }
    
    private func enterApp() {
        tabBarCoordinator = TabBarCoordinator(window: window, transitions: self, serviceHolder: serviceHolder)
        tabBarCoordinator?.start()
        authFlowCoordinator = nil
    }
    
    deinit {
        debugPrint("APPCOORDINATOR DEINIT !!!!!!!!!!!!!!!!!!!!!!")
    }
}

extension AppCoordinator {
    private func startInitialServices() {
        let fbAuthorization = FBAuthorization()
        let firebaseAgent = FirebaseAgent()
        let contactsProvider = ContactsProvider(user: User())
        serviceHolder.add(FBAuthorization.self, for: fbAuthorization)
        serviceHolder.add(FirebaseAgent.self, for: firebaseAgent)
        serviceHolder.add(ContactsProvider.self, for: contactsProvider)
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
        //TODO(Serhii K.) Will delete debugPrint after fix coordinators work (prevent deinit)
        debugPrint("Huray !!!!!!!!!!!!!!!!")
    }
}
