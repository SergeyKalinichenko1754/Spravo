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
    private var authFlowCoordinator: AuthFlowCoordinator?
    private var serviceHolder = ServiceHolder()
    
    init(window: UIWindow) {
        self.window = window
        start()
    }
    
    private func start() {
        authorizationStart()
    }
    
    private func authorizationStart() {
        authFlowCoordinator = AuthFlowCoordinator(window: window, transitions: self, serviceHolder: serviceHolder)
        authFlowCoordinator?.start()
    }
    
    private func enterApp() {
        debugPrint("Start AddressBookTabBarCoordinator **************")
        authFlowCoordinator = nil
    }
}

extension AppCoordinator: AuthFlowCoordinatorTransitions {
    func userDidLogin() {
        enterApp()
    }
}
