//
//  FavouritesTabCoordinator.swift
//  Spravo
//
//  Created by Onix on 10/30/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol FavouritesTabCoordinatorTransitions: class {
}

class FavouritesTabCoordinator: TabBarItemCoordinatorType {
    var rootController = UINavigationController()
    var tabBarItem = UITabBarItem(title: "Favourites.Title".localized, image: UIImage(named: "favourites"), selectedImage: nil)
    private weak var transitions: FavouritesTabCoordinatorTransitions?
    private var serviceHolder: ServiceHolder
    
    init(serviceHolder: ServiceHolder, transitions: FavouritesTabCoordinatorTransitions) {
        self.serviceHolder = serviceHolder
        self.transitions = transitions
    }
    
    func start() {
        rootController.tabBarItem = tabBarItem
        let coordinator = FavouritesCoordinator(navigationController: rootController, transitions: self, serviceHolder: serviceHolder)
        coordinator.start()
    }
}

extension FavouritesTabCoordinator: FavouritesCoordinatorTransitions {
    
}
