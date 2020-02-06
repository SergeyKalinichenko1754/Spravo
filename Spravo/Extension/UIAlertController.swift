//
//  UIAlertController.swift
//  Spravo
//
//  Created by Onix on 11/26/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

extension UIAlertController {
    func pruneNegativeWidthConstraints() {
        for subView in self.view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}
