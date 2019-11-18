//
//  ContactDetailsPhoneCell.swift
//  Spravo
//
//  Created by Onix on 11/15/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol SendSMSButtonDelegate: class {
    func sendSMS(_ to: String)
}

class ContactDetailsPhoneCell: UITableViewCell {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var smsButton: UIButton!
    
    weak var delegate: SendSMSButtonDelegate?
    
    @IBAction func smsButtonTaped(_ sender: UIButton) {
        guard let smsTo = valueLabel.text else { return }
        delegate?.sendSMS(smsTo)
    }
}
