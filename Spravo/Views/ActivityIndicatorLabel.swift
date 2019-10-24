//
//  ActivityIndicatorLabel.swift
//  Spravo
//
//  Created by Onix on 10/22/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class ActivityIndicatorLabel: UIView {
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    private func customInit() {
        self.nibSetup()
        self.label.text = ""
        self.stopIndicator()
    }
    
    func startIndicator() {
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
    }
    
    func stopIndicator() {
        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
    }
}
