//
//  FavouritesCoordinator.swift
//  Spravo
//
//  Created by Onix on 10/30/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol FavouritesCoordinatorTransitions: class {
}

protocol FavouritesCoordinatorType: class {
}

class FavouritesCoordinator: FavouritesCoordinatorType {
    private weak var navigationController: UINavigationController?
    private weak var transitions: FavouritesCoordinatorTransitions?
    private weak var controller = Storyboard.favourites.controller(withClass: FavouritesVC.self)
    private var serviceHolder: ServiceHolder
    
    init(navigationController: UINavigationController?, transitions: FavouritesCoordinatorTransitions, serviceHolder: ServiceHolder) {
        self.navigationController = navigationController
        self.transitions = transitions
        self.serviceHolder = serviceHolder
        controller?.viewModel = FavouritesViewModel(self, serviceHolder: serviceHolder)
    }
    
    func start() {
        if let controller = controller {
            navigationController?.setViewControllers([controller], animated: true)
        }
    }
}
