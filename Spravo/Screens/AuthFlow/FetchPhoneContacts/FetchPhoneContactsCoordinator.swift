//
//  FetchPhoneContactsCoordinator.swift
//  Spravo
//
//  Created by Onix on 10/10/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol FetcPhoneContactsCoordinatorTransitions: class {
    func userDidLogin()
    func userInterruptedProgram()
}

protocol FetchPhoneContactsCoordinatorType {
    func userDidLogin()
    func userInterruptedProgram()
    func startActivityScreen(labels: [String])
    func starNextActivityIndicator()
    func stopActivityIndicator()
}

class FetchPhoneContactsCoordinator: FetchPhoneContactsCoordinatorType {
    private weak var navigationController: UINavigationController?
    private weak var controller = Storyboard.auth.controller(withClass: FetchPhoneContactsVC.self)
    private weak var transitions: FetcPhoneContactsCoordinatorTransitions?
    private var serviceHolder: ServiceHolder
    private var activityScreenCoordinator: ActivityScreenCoordinator? = nil
    
    init(navigationController: UINavigationController?, transitions: FetcPhoneContactsCoordinatorTransitions, serviceHolder: ServiceHolder) {
        self.navigationController = navigationController
        self.transitions = transitions
        self.serviceHolder = serviceHolder
        controller?.viewModel = FetchPhoneContactsViewModel(self, serviceHolder: serviceHolder)
    }
    
    func start() {
        guard let controller = controller else { return }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func userDidLogin() {
        transitions?.userDidLogin()
    }
    
    func userInterruptedProgram() {
        transitions?.userInterruptedProgram()
    }
}

extension FetchPhoneContactsCoordinator: ActivityScreenCoordinatorTransitions {
    func startActivityScreen(labels: [String]) {
        guard let navigation = navigationController else { return }
        activityScreenCoordinator = ActivityScreenCoordinator(navigationController: navigation, transitions: self, labels: labels)
        activityScreenCoordinator?.start()
    }
    
    func starNextActivityIndicator() {
        guard let activityScreenCoordinator = activityScreenCoordinator else { return }
        activityScreenCoordinator.starNextActivityIndicator()
    }
    
    func stopActivityIndicator() {
        activityScreenCoordinator = nil
    }
    
    func cancelAction() {
        userInterruptedProgram()
    }
}
