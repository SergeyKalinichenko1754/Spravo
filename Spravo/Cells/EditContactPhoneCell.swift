//
//  EditContactPhoneCell.swift
//  Spravo
//
//  Created by Onix on 11/27/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class EditContactPhoneCell: UITableViewCell {
    @IBOutlet weak var labelMarkButton: UIButton!
    @IBOutlet weak var valueTextField: UITextField!
    
    weak var delegate: TVCellButtonActionAndTextFieldDelegate?
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        valueTextField.addBorder(.left, color: .lightGray, thickness: 1)
        valueTextField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
        valueTextField.leftViewMode = .always
    }

    @IBAction func labelMarkButtonTaped(_ sender: UIButton) {
        delegate?.buttonInTableViewTaped(.labelMark, indexPath: indexPath)
    }
    
    @IBAction func beginEditTextField(_ sender: UITextField) {
        guard let section = indexPath?.section else { return }
        switch section {
        case 1:
            valueTextField.keyboardType = UIKeyboardType.phonePad
        case 2:
            valueTextField.keyboardType = UIKeyboardType.emailAddress
        default: break
        }
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        delegate?.textFieldDidChange(.oneTextFieldInCell(sender.text), indexPath: indexPath)
    }
}
