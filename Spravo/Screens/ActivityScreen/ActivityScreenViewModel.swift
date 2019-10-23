//
//  ActivityScreenViewModel.swift
//  Spravo
//
//  Created by Onix on 10/22/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

protocol ActivityScreenViewModelType {
    var quoantityIndicators: Int { get }
    var topLabelText: String { get }
    var bottomLabelText: String { get }
    func cancelAction()
}

class ActivityScreenViewModel: ActivityScreenViewModelType {
    fileprivate let coordinator: ActivityScreenCoordinatorType
    var labels = [String]()
    
    var quoantityIndicators: Int {
        return labels.count
    }
    
    var topLabelText: String {
        return labels[0]
    }
    
    var bottomLabelText: String {
        return quoantityIndicators > 1 ? labels[1] : ""
    }
    
    init(_ coordinator: ActivityScreenCoordinatorType, labels: [String]) {
        self.coordinator = coordinator
        self.labels = labels
    }
    
    func cancelAction() {
        coordinator.cancelAction()
    }
}
