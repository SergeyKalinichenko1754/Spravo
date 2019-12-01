//
//  FavouritesVC.swift
//  Spravo
//
//  Created by Onix on 10/30/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import MessageUI

protocol FavouritesVCButtonActionDelegate: class {
    func buttonInTableViewTaped(_ indexPath: IndexPath)
}

class FavouritesVC: UIViewController {
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: FavouritesViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        localizeScreen()
        setup()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupEditButton()
        tableView.reloadData()
    }
    
    private func localizeScreen() {
        editButton.title = NSLocalizedString("Favourites.EditButtonCaption", comment: "Caption for edit button")
    }
    
    private func setup() {
        navigationController?.navigationBar.tintColor = DefaultColors.navigationTintColor
    }
    
    private func setupEditButton() {
        editButton.isEnabled = viewModel.getNumberOfRows(section: 0) > 0
    }
    
    @IBAction func editButtonTaped(_ sender: UIBarButtonItem) {
        tableView.isEditing = !tableView.isEditing
        editButton.title = tableView.isEditing ? NSLocalizedString("Favourites.DoneButtonCaption", comment: "Caption for done button") :
            NSLocalizedString("Favourites.EditButtonCaption", comment: "Caption for edit button")
    }
 }

extension FavouritesVC: UITableViewDataSource {
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
    }
}

extension FavouritesVC: UITableViewDelegate, MFMessageComposeViewControllerDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.openCommunicationVC(indexPath, inVC: self)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .sent:
            //TODO(Serhii K) input notif. into recent
            debugPrint("Sent")
        default: break
        }
        controller.dismiss(animated: true, completion: nil)
    }
}

extension FavouritesVC: FavouritesVCButtonActionDelegate {
    func buttonInTableViewTaped(_ indexPath: IndexPath) {
        viewModel.showContactDetails(indexPath)
    }
}

extension FavouritesVC {
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.moveRow(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteRow(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            setupEditButton()
        }
    }
}
