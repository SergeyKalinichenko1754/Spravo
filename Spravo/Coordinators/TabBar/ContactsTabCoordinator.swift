//
//  ContactsTabCoordinator.swift
//  Spravo
//
//  Created by Onix on 10/30/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol ContactsTabCoordinatorTransitions: class {
    func startFetchPhoneContacts()
}

class ContactsTabCoordinator: TabBarItemCoordinatorType {
    let rootController = UINavigationController()
    let tabBarItem = UITabBarItem(title: "Contacts.Title".localized, image: UIImage(named: "contacts"), selectedImage: nil)
    private weak var transitions: ContactsTabCoordinatorTransitions?
    private var serviceHolder: ServiceHolder
    
    init(serviceHolder: ServiceHolder, transitions: ContactsTabCoordinatorTransitions) {
        self.serviceHolder = serviceHolder
        self.transitions = transitions
    }
    
    func start() {
        rootController.tabBarItem = tabBarItem
        let coordinator = ContactsCoordinator(navigationController: rootController, transitions: self, serviceHolder: serviceHolder)
        coordinator.start()
    }
    
    deinit {
        debugPrint("ContactsTabCoordinator DEINIT !!!!")
    }
    
}

extension ContactsTabCoordinator: ContactsCoordinatorTransitions {
    func startFetchPhoneContacts() {
        transitions?.startFetchPhoneContacts()
    }
}
