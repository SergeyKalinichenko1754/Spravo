//
//  ActivityScreenVC.swift
//  Spravo
//
//  Created by Onix on 10/22/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class ActivityScreenVC: UIViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var topActivityIndicatorLabel: ActivityIndicatorLabel!
    @IBOutlet weak var bottomActivityIndicatorLabel: ActivityIndicatorLabel!
    @IBOutlet weak var actionButton: ActionButton!
    var viewModel: ActivityScreenViewModelType!
    var activeIndicator = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    func setupScreen() {
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = UIColor(red: 13.0/255.0, green: 145.0/255.0, blue: 1.0, alpha: 1.0)
        topActivityIndicatorLabel.activityIndicatorView.color = .white
        topActivityIndicatorLabel.startIndicator()
        topActivityIndicatorLabel.label.text = viewModel.topLabelText
        bottomActivityIndicatorLabel.label.text = viewModel.bottomLabelText
        bottomActivityIndicatorLabel.activityIndicatorView.color = .white
        actionButton.customSetup(delegate: self)
        actionButton.button.backgroundColor = UIColor(red: 170.0/255.0, green: 168.0/255.0, blue: 170.0/255.0, alpha: 1.0)
        actionButton.button.setTitleColor(.black, for: .normal)
    }
    
    func starNextActivityIndicator() {
        activeIndicator += 1
        if activeIndicator == viewModel.quoantityIndicators {
            self.dismiss(animated: true, completion: nil)
        } else {
            topActivityIndicatorLabel.stopIndicator()
            bottomActivityIndicatorLabel.startIndicator()
        }
    }    
}

extension ActivityScreenVC: ActionButtonDelegate {
    func buttonTapedAction() {
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.viewModel.cancelAction()
        }
    }
}
