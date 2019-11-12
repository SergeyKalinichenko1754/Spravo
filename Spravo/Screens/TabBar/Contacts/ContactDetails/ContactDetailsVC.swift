//
//  ContactDetailsVC.swift
//  Spravo
//
//  Created by Onix on 11/12/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class ContactDetailsVC: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    var viewModel: ContactDetailsViewModelType!

    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = viewModel.fullName()
    }
}
