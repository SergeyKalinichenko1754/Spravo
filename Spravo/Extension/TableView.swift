//
//  TableView.swift
//  Spravo
//
//  Created by Onix on 12/6/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

extension UITableView {
    func reloadData(completion: @escaping () -> ()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData()})
        {_ in completion() }
    }
}
