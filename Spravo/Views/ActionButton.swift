//
//  ActionButton.swift
//  Spravo
//
//  Created by Onix on 10/23/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol ActionButtonDelegate: class {
    func buttonTapedAction()
}

class ActionButton: UIButton {
    @IBOutlet weak var button: UIButton!
    
    private weak var delegate: ActionButtonDelegate?
    
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
    }
    
    func customSetup(delegate: ActionButtonDelegate, buttonCaption: String? = nil) {
        self.delegate = delegate
        let btnCaption = buttonCaption != nil ? buttonCaption : "Common.Cancel".localized
        button.setTitle(btnCaption, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
    }
    
    @IBAction func buttonTapedAction(_ sender: UIButton) {
        delegate?.buttonTapedAction()
    }
}
