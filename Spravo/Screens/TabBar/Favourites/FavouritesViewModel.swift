//
//  FavouritesViewModel.swift
//  Spravo
//
//  Created by Onix on 10/30/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

protocol FavouritesViewModelType {
}

class FavouritesViewModel: FavouritesViewModelType {
    fileprivate let coordinator: FavouritesCoordinatorType
    private var serviceHolder: ServiceHolder
    
    init(_ coordinator: FavouritesCoordinatorType, serviceHolder: ServiceHolder) {
        self.coordinator = coordinator
        self.serviceHolder = serviceHolder
    }
}
