//
//  EditContactNotesCell.swift
//  Spravo
//
//  Created by Onix on 11/26/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class EditContactNotesCell: UITableViewCell {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    weak var delegate: TVCellButtonActionAndTextFieldDelegate?
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.delegate = self
    }
}

extension EditContactNotesCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        delegate?.textFieldDidChange(.notes(textView.text), indexPath: indexPath)
    }
}
