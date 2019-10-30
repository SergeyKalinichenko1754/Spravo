//
//  RecentsTabCoordinator.swift
//  Spravo
//
//  Created by Onix on 10/30/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol RecentsTabCoordinatorTransitions: class {
}

class RecentsTabCoordinator: TabBarItemCoordinatorType {
    var rootController = UINavigationController()
    var tabBarItem = UITabBarItem(title: "Recents.Title".localized, image: UIImage(named: "recents"), selectedImage: nil)
    private weak var transitions: RecentsTabCoordinatorTransitions?
    private var serviceHolder: ServiceHolder
    
    init(serviceHolder: ServiceHolder, transitions: RecentsTabCoordinatorTransitions) {
        self.serviceHolder = serviceHolder
        self.transitions = transitions
    }
    
    func start() {
        rootController.tabBarItem = tabBarItem
        let coordinator = RecentsCoordinator(navigationController: rootController, transitions: self, serviceHolder: serviceHolder)
        coordinator.start()
    }
}

extension RecentsTabCoordinator: RecentsCoordinatorTransitions {
    
}
