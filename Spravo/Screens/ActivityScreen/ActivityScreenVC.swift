//
//  ActivityScreenVC.swift
//  Spravo
//
//  Created by Onix on 10/22/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol ActivityScreenDelegate: class {
    func userInterruptedAction()
}

class ActivityScreenVC: UIViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var topActivityIndicatorLabel: ActivityIndicatorLabel!
    @IBOutlet weak var bottomActivityIndicatorLabel: ActivityIndicatorLabel!
    @IBOutlet weak var actionButton: ActionButton!
    
    weak var parentDelegate: ActivityScreenDelegate?
    fileprivate var activeIndicator = 0
    var labels = [String]() {
        didSet {
            activeIndicator = 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    fileprivate func setupScreen() {
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = RGBAColor(13, 145, 1, 1)
        topActivityIndicatorLabel.activityIndicatorView.color = .white
        topActivityIndicatorLabel.startIndicator()
        bottomActivityIndicatorLabel.activityIndicatorView.color = .white
        actionButton.customSetup(delegate: self)
        actionButton.button.backgroundColor = RGBAColor(170, 168, 170, 1)
        actionButton.button.setTitleColor(.black, for: .normal)
        setLabelText()
    }
    
    fileprivate func setLabelText() {
        let topElementNumber = activeIndicator / 2 * 2
        let topLabelText = labels.count > topElementNumber ? labels[topElementNumber] : ""
        topActivityIndicatorLabel.label.text = topLabelText
        let bottomLabelText = labels.count > topElementNumber + 1 ? labels[topElementNumber + 1] : ""
        bottomActivityIndicatorLabel.label.text = bottomLabelText
    }
    
    func starNextActivityIndicator() {
        activeIndicator += 1
        guard activeIndicator != labels.count else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        if activeIndicator % 2 == 0 {
           setLabelText()
            topActivityIndicatorLabel.startIndicator()
            bottomActivityIndicatorLabel.stopIndicator()
        } else {
            topActivityIndicatorLabel.stopIndicator()
            bottomActivityIndicatorLabel.startIndicator()
        }
    }
    
    func stopActivityIndicator(completion: @escaping EmptyClosure) {
        self.dismiss(animated: false, completion: {
            completion()
        })
    }
}

extension ActivityScreenVC: ActionButtonDelegate {
    func buttonTapedAction() {
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.parentDelegate?.userInterruptedAction()
        }
    }
}
