//
//  MapPopUpMapTypeCell.swift
//  Spravo
//
//  Created by Onix on 11/21/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class MapPopUpMapTypeCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var segmentedButton: UISegmentedControl!
    
    weak var delegate: MapPopUpVCButtonActionDelegate?
    var indexPath: IndexPath?
    
    @IBAction func segmentedButtonTaped(_ sender: UISegmentedControl) {
        delegate?.buttonInTableViewTaped(.mapType(sender.selectedSegmentIndex), indexPath: indexPath)
    }
}
