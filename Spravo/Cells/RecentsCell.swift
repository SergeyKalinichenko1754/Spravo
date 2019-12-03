//
//  RecentsCell.swift
//  Spravo
//
//  Created by Onix on 12/3/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class RecentsCell: UITableViewCell {

    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var callConnectStateImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    weak var delegate: RecentsVCButtonActionDelegate?
    var indexPath: IndexPath?
    
    @IBAction func informationButtonTaped(_ sender: UIButton) {
        guard let index = indexPath else { return }
        delegate?.buttonInTableViewTaped(index)
    }
}
