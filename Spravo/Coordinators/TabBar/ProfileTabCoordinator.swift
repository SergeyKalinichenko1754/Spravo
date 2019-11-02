//
//  ProfileTabCoordinator.swift
//  Spravo
//
//  Created by Onix on 10/30/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol ProfileTabCoordinatorTransitions: class {
    func logout()
}

class ProfileTabCoordinator: TabBarItemCoordinatorType {
    let rootController = UINavigationController()
    let tabBarItem = UITabBarItem(title: "Profile.Title".localized, image: UIImage(named: "profile"), selectedImage: nil)
    private weak var transitions: ProfileTabCoordinatorTransitions?
    private var serviceHolder: ServiceHolder
    
    init(serviceHolder: ServiceHolder, transitions: ProfileTabCoordinatorTransitions) {
        self.serviceHolder = serviceHolder
        self.transitions = transitions
    }
    
    func start() {
        rootController.tabBarItem = tabBarItem
        let coordinator = ProfileCoordinator(navigationController: rootController, transitions: self, serviceHolder: serviceHolder)
        coordinator.start()
    }
}

extension ProfileTabCoordinator: ProfileCoordinatorTransitions {
    func logout() {
        transitions?.logout()
    }
}
