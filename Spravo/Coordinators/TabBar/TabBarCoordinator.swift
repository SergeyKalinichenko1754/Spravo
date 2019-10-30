//
//  TabBarCoordinator.swift
//  Spravo
//
//  Created by Onix on 10/30/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol TabBarCoordinatorTransitions: class {
    func logout()
}

protocol TabBarItemCoordinatorType {
    var rootController: UINavigationController { get }
    var tabBarItem: UITabBarItem { get }
}

class TabBarCoordinator {
    private weak var window: UIWindow?
    private weak var transitions: TabBarCoordinatorTransitions?
    private let serviceHolder: ServiceHolder
    private let tabBarController = UITabBarController()
    private var tabCoordinators:[TabBarItemCoordinatorType] = []
    
    init(window: UIWindow, transitions: TabBarCoordinatorTransitions, serviceHolder: ServiceHolder) {
        self.window = window
        self.serviceHolder = serviceHolder
        self.transitions = transitions
        tabBarController.tabBar.barTintColor = RGBColor(247, 247, 247)
        tabBarController.tabBar.tintColor = RGBColor(33, 49, 205)
        let firstTabCoord = FavouritesTabCoordinator(serviceHolder: serviceHolder, transitions: self)
        firstTabCoord.start()
        let secondTabCoord = RecentsTabCoordinator(serviceHolder: serviceHolder, transitions: self)
        secondTabCoord.start()
        let thirdTabCoord = ContactsTabCoordinator(serviceHolder: serviceHolder, transitions: self)
        thirdTabCoord.start()
        let fourthTabCoord = ProfileTabCoordinator(serviceHolder: serviceHolder, transitions: self)
        fourthTabCoord.start()
        tabCoordinators = [firstTabCoord, secondTabCoord, thirdTabCoord, fourthTabCoord]
        tabBarController.viewControllers = [firstTabCoord.rootController, secondTabCoord.rootController, thirdTabCoord.rootController, fourthTabCoord.rootController]
        tabBarController.selectedIndex = 2
    }
    
    func start(animated: Bool = false) {
        guard let window = window else { return }
        if (animated) {
            UIView.transition(with: window, duration: 0.5, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { [weak self] in
                window.rootViewController = self?.tabBarController
                }, completion: nil)
        } else {
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        }
    }
}

extension TabBarCoordinator: FavouritesTabCoordinatorTransitions {
}

extension TabBarCoordinator: RecentsTabCoordinatorTransitions {
}

extension TabBarCoordinator: ContactsTabCoordinatorTransitions {
}

extension TabBarCoordinator: ProfileTabCoordinatorTransitions {
}
