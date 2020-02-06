//
//  PopupMenuAddNewLabelCell.swift
//  Spravo
//
//  Created by Onix on 11/29/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class PopupMenuAddNewLabelCell: UITableViewCell {
    @IBOutlet weak var newLabelTextField: UITextField!
    @IBOutlet weak var addNewLabelButton: UIButton!
    
    weak var delegate: AddNewLabelInTextFieldPopupMenuDelegate?
    
    @IBAction func addNewLabelButtonTaped(_ sender: UIButton) {
        sender.isHidden = true
        newLabelTextField.isHidden = false
        newLabelTextField.becomeFirstResponder()
    }
    
    @IBAction func tapedEnter(_ sender: UITextField) {
        newLabelTextField.resignFirstResponder()
        sender.isHidden = true
        addNewLabelButton.isHidden = false
        delegate?.addNewLabel(sender.text)
    }
}
