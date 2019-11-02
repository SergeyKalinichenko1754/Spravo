//
//  ProfileViewModel.swift
//  Spravo
//
//  Created by Onix on 10/30/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

protocol ProfileViewModelType {
    func logout()
}

class ProfileViewModel: ProfileViewModelType {
    fileprivate let coordinator: ProfileCoordinatorType
    private var serviceHolder: ServiceHolder
    
    init(_ coordinator: ProfileCoordinatorType, serviceHolder: ServiceHolder) {
        self.coordinator = coordinator
        self.serviceHolder = serviceHolder
    }
    
    func logout() {
        coordinator.logout()
    }
}
