//
//  EditContactPhotoNameCell.swift
//  Spravo
//
//  Created by Onix on 11/25/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class EditContactPhotoNameCell: UITableViewCell {
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var givenNameTextField: UITextField!
    @IBOutlet weak var middleNameTextField: UITextField!
    @IBOutlet weak var familyNameTextField: UITextField!
    
    weak var delegate: TVCellButtonActionAndTextFieldDelegate?
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageButton.layer.cornerRadius = profileImageButton.frame.height / 2
        profileImageButton.layer.masksToBounds = true
        setTextField(givenNameTextField)
        setTextField(middleNameTextField)
        setTextField(familyNameTextField)
    }
    
    private func setTextField(_ field: UITextField) {
        field.addBorder(.bottom, color: .lightGray, thickness: 1)
        field.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
        field.leftViewMode = .always
    }
    
    @IBAction func profileImageTaped(_ sender: UIButton) {
        delegate?.buttonInTableViewTaped(.profileImage, indexPath: indexPath)
    }
    
    @IBAction func givenNameChanged(_ sender: UITextField) {
        delegate?.textFieldDidChange(.givenName(sender.text), indexPath: indexPath)
    }
    
    @IBAction func middleNameChanged(_ sender: UITextField) {
        delegate?.textFieldDidChange(.middleName(sender.text), indexPath: indexPath)
    }
    
    @IBAction func familyNameChanged(_ sender: UITextField) {
        delegate?.textFieldDidChange(.familyName(sender.text), indexPath: indexPath)
    }
}
