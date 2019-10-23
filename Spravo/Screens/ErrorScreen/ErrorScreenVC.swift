//
//  ErrorScreenVC.swift
//  Spravo
//
//  Created by Onix on 10/23/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class ErrorScreenVC: UIViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var actionButton: ActionButton!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    var image: UIImage?
    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    fileprivate func setupScreen() {
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = UIColor(red: 170.0/255.0, green: 168.0/255.0, blue: 170.0/255.0, alpha: 1.0)
        actionButton.customSetup(delegate: self)
        actionButton.button.backgroundColor = UIColor(red: 13.0/255.0, green: 145.0/255.0, blue: 1.0, alpha: 1.0)
        actionButton.button.setTitleColor(.black, for: .normal)
        imageView.backgroundColor = .clear
        if let image = image {
            imageView.image = image
        } else {
            imageViewHeightConstraint.constant = 0
        }        
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.isUserInteractionEnabled = true
        textView.isSelectable = true
        textView.isEditable = false
        textView.dataDetectorTypes = UIDataDetectorTypes.link
        textView.text = text
        textView.backgroundColor = .clear
        textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.blue]
        textView.sizeToFit()
    }
    
}

extension ErrorScreenVC: ActionButtonDelegate {
    func buttonTapedAction() {
        self.dismiss(animated: true, completion: nil)
    }
}
