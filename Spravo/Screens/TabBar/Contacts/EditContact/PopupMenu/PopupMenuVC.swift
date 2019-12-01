//
//  PopupMenuVC.swift
//  Spravo
//
//  Created by Onix on 11/28/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol PopupMenuDelegate {
    func getNewValueFromPopup(popupMenuType: PopupMenuType, currentValue: String?, forIndexPath: IndexPath?)
    func returnNewValueFromPopup(newValue: String?, for: PopupMenuType, forIndexPath: IndexPath?)
}

protocol AddNewLabelInTextFieldPopupMenuDelegate: class {
    func addNewLabel(_ value: String?)
}

class PopupMenuVC: TemplateKeyboardAvoidVC {
    @IBOutlet weak var contextView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: PopupMenuViewModel!
    var delegate: PopupMenuDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
        setupTableView()
    }
    
    func setupScreen() {
        contextView.layer.cornerRadius = 5
        contextView.layer.masksToBounds = true
    }
    
    func returnData() {
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            let newValue = self.viewModel.getCurrentValue()
            let forIndexPath = self.viewModel.getForIndexPath()
            let popupMenuType = self.viewModel.getPopupMenuType()
            self.delegate?.returnNewValueFromPopup(newValue: newValue, for: popupMenuType, forIndexPath: forIndexPath)
        }
    }
    
    @IBAction func cancelButtonTaped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension PopupMenuVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.getNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 15 
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRows(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return viewModel.cellForTableView(tableView: tableView, atIndexPath: indexPath, delegate: self)
    }
    
    private func setupTableView() {
        viewModel.registerCells(for: tableView)
        tableView.tableFooterView = UIView()
        tableView.separatorInset.left = 10
        tableView.separatorInset.right = 10
        tableView.rowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .interactive
    }
}

extension PopupMenuVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.setNewValue(indexPath)
        returnData()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return viewModel.trailingSwipeActions(tableView, indexPath: indexPath)
    }
}

extension PopupMenuVC: AddNewLabelInTextFieldPopupMenuDelegate {
    func addNewLabel(_ value: String?) {
        guard let value = value?.trimmingCharacters(in: .whitespaces), value.count > 0 else { return }
        viewModel.addNewLabel(tableView, value: value)
        returnData()
    }
}
