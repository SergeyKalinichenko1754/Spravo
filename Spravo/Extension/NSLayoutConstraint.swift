//
//  NSLayoutConstraint.swift
//  Spravo
//
//  Created by Onix on 12/6/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    static func setMultiplier(_ multiplier: CGFloat, of constraint: inout NSLayoutConstraint) {
        NSLayoutConstraint.deactivate([constraint])
        let newConstraint = NSLayoutConstraint(item: constraint.firstItem as Any, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: constraint.secondItem, attribute: constraint.secondAttribute, multiplier: multiplier, constant: constraint.constant)
        newConstraint.priority = constraint.priority
        newConstraint.shouldBeArchived = constraint.shouldBeArchived
        newConstraint.identifier = constraint.identifier
        NSLayoutConstraint.activate([newConstraint])
        constraint = newConstraint
    }
}
