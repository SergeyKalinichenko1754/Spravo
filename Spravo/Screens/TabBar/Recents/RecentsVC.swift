//
//  RecentsVC.swift
//  Spravo
//
//  Created by Onix on 10/30/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol RecentsVCButtonActionDelegate: class {
    func buttonInTableViewTaped(_ indexPath: IndexPath)
}

class RecentsVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: RecentsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = NSLocalizedString("Recents.Title", comment: "Screen title")
        tableView.reloadData()
    }
    
    private func setup() {
        navigationController?.navigationBar.tintColor = DefaultColors.navigationTintColor
    }
}

extension RecentsVC: RecentsVCButtonActionDelegate {
    func buttonInTableViewTaped(_ indexPath: IndexPath) {
        viewModel.showContactDetails(indexPath)
    }
}

extension RecentsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRows(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return viewModel.cellForTableView(tableView: tableView, atIndexPath: indexPath, buttonsDelegate: self)
    }
    
    private func setupTableView() {
        viewModel.registerCells(for: tableView)
        tableView.tableFooterView = UIView()
        tableView.separatorInset.left = 10
        tableView.separatorInset.right = 10
        tableView.allowsSelection = false
    }
}

extension RecentsVC {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteRow(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
