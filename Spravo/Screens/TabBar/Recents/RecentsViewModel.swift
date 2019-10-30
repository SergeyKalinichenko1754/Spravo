//
//  RecentsViewModel.swift
//  Spravo
//
//  Created by Onix on 10/30/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

protocol RecentsViewModelType {
}

class RecentsViewModel: RecentsViewModelType {
    fileprivate let coordinator: RecentsCoordinatorType
    private var serviceHolder: ServiceHolder
    
    init(_ coordinator: RecentsCoordinatorType, serviceHolder: ServiceHolder) {
        self.coordinator = coordinator
        self.serviceHolder = serviceHolder
    }
}
