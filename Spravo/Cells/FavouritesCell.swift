//
//  FavouritesCell.swift
//  Spravo
//
//  Created by Onix on 11/22/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class FavouritesCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var prefixLabel: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    weak var delegate: FavouritesVCButtonActionDelegate?
    var indexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.layer.masksToBounds = true
    }
    
    @IBAction func informationButtonTaped(_ sender: UIButton) {
        guard let index = indexPath else { return }
        delegate?.buttonInTableViewTaped(index)
    }
}
