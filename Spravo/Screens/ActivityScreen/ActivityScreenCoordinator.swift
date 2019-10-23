//
//  ActivityScreenCoordinator.swift
//  Spravo
//
//  Created by Onix on 10/22/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol ActivityScreenCoordinatorTransitions: class {
    func cancelAction()
}

protocol ActivityScreenCoordinatorType {
    func starNextActivityIndicator()
    func cancelAction()
}

class ActivityScreenCoordinator: ActivityScreenCoordinatorType {
    private weak var navigationController: UINavigationController?
    private weak var controller = Storyboard.service.controller(withClass: ActivityScreenVC.self)
    private weak var transitions: ActivityScreenCoordinatorTransitions?
    
    init(navigationController: UINavigationController?, transitions: ActivityScreenCoordinatorTransitions, labels: [String]) {
        self.navigationController = navigationController
        self.transitions = transitions
        controller?.viewModel = ActivityScreenViewModel(self, labels: labels)
    }
    
    func start() {
        guard let controller = controller else { return }
        navigationController?.modalPresentationStyle = .overCurrentContext
        navigationController?.present(controller, animated: true, completion: nil)
    }
    
    func starNextActivityIndicator() {
        controller?.starNextActivityIndicator()
    }
    
    func cancelAction() {
        transitions?.cancelAction()
    }
}
