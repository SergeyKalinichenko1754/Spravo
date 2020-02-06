//
//  EditContactAddressCell.swift
//  Spravo
//
//  Created by Onix on 11/28/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class EditContactAddressCell: UITableViewCell {
    @IBOutlet weak var labelMarkButton: UIButton!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var countryButton: UIButton!
    
    weak var delegate: TVCellButtonActionAndTextFieldDelegate?
    var indexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        setTextField(postalCodeTextField)
        setTextField(streetTextField)
        setTextField(cityTextField)
        setTextField(stateTextField)
        countryButton.addBorder(.bottom, color: .lightGray, thickness: 1)
    }
    
    private func setTextField(_ field: UITextField) {
        field.addBorder(.bottom, color: .lightGray, thickness: 1)
        field.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
        field.leftViewMode = .always
    }
    
    @IBAction func labelMarkButtonTaped(_ sender: UIButton) {
        delegate?.buttonInTableViewTaped(.labelMark, indexPath: indexPath)
    }
    
    @IBAction func countryButtonTaped(_ sender: UIButton) {
        delegate?.buttonInTableViewTaped(.country, indexPath: indexPath)
    }
    
    @IBAction func postalCodeChanged(_ sender: UITextField) {
        delegate?.textFieldDidChange(.postalCode(sender.text), indexPath: indexPath)
    }
    
    @IBAction func streetChanged(_ sender: UITextField) {
        delegate?.textFieldDidChange(.street(sender.text), indexPath: indexPath)
    }
    
    @IBAction func cityChanged(_ sender: UITextField) {
        delegate?.textFieldDidChange(.city(sender.text), indexPath: indexPath)
    }
    
    @IBAction func stateChanged(_ sender: UITextField) {
        delegate?.textFieldDidChange(.state(sender.text), indexPath: indexPath)
    }
}
