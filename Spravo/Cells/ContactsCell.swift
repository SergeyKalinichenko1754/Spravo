//
//  ContactsCell.swift
//  Spravo
//
//  Created by Onix on 10/30/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class ContactsCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    func customInit(contact: Contact) {
        nameLabel.text = contact.fullName
    }
}
