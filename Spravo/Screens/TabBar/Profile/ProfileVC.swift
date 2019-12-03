//
//  ProfileVC.swift
//  Spravo
//
//  Created by Onix on 10/30/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    
    var viewModel: ProfileViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = NSLocalizedString("Profile.Title", comment: "Screen title")
    }
    
    private func setupScreen() {
        logOutButton.title = NSLocalizedString("Profile.LogOutBtnCaption", comment: "Caption for log Out button")
    }
    
    @IBAction func logOutButtonTaped(_ sender: UIBarButtonItem) {
        viewModel.logout()
    }
}

extension ProfileVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRows(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return viewModel.cellForTableView(tableView: tableView, atIndexPath: indexPath)
    }
    
    private func setupTableView() {
        viewModel.registerCells(for: tableView)
        tableView.tableFooterView = UIView()
        tableView.separatorInset.left = 10
        tableView.separatorInset.right = 10
    }
}
