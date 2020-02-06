//
//  EditContactVC.swift
//  Spravo
//
//  Created by Onix on 11/17/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

enum EditContactButtonType {
    case profileImage
    case labelMark
    case country
}

enum EditContactTextFieldType {
    case givenName(String?)
    case middleName(String?)
    case familyName(String?)
    case notes(String?)
    case oneTextFieldInCell(String?)
    case postalCode(String?)
    case street(String?)
    case city(String?)
    case state(String?)
}

protocol TVCellButtonActionAndTextFieldDelegate: class {
    func buttonInTableViewTaped(_ btnType: EditContactButtonType, indexPath: IndexPath?)
    func textFieldDidChange(_ value: EditContactTextFieldType, indexPath: IndexPath?)
}

class EditContactVC: TemplateKeyboardAvoidVC {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var viewModel: EditContactViewModelType!
    var imagePicker: CustomImagePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupScreen()
        self.imagePicker = CustomImagePicker(self, delegate: self)
    }
    
    private func setupScreen() {
        saveButton.isEnabled = false
        saveButton.title = NSLocalizedString("EditContacts.SaveButtonCaption", comment: "Caption for save button")
    }
    
    @IBAction func saveButtonTaped(_ sender: UIBarButtonItem) {
        viewModel.saveContact()
    }
}

extension EditContactVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.getNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRows(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = viewModel.cellForTableView(tableView: tableView, atIndexPath: indexPath, buttonDelegate: self)
        return cell
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

extension EditContactVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectRowAt(tableView, indexPath: indexPath, rootVC: self) { [weak self] in
            guard let self = self else { return }
            self.setSaveButton()
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return viewModel.trailingSwipeActions(tableView, indexPath: indexPath)
    }
}

extension EditContactVC: TVCellButtonActionAndTextFieldDelegate {
    func buttonInTableViewTaped(_ btnType: EditContactButtonType, indexPath: IndexPath?) {
        let tapedBtn = (btnType, (indexPath?.row ?? 999))
        switch tapedBtn {
        case (.profileImage, _):
            let currentImage = viewModel.getCurrentImage()
            imagePicker.present(from: self.view, indexPath: indexPath, currentImage: currentImage)
        case (.labelMark, _):
            let section = indexPath?.section ?? -1
            var popupMenuType: PopupMenuType
            switch section {
            case 2:
                popupMenuType = .emailLabel
            case 3:
                popupMenuType = .addressLabel
            default:
                popupMenuType = .phoneLabel
            }
            let currentValue = viewModel.curentLabel(forIndexPath: indexPath, labelType: popupMenuType)
            getNewValueFromPopup(popupMenuType: popupMenuType, currentValue: currentValue, forIndexPath: indexPath)
        case (.country, _):
            let currentValue = viewModel.curentLabel(forIndexPath: indexPath, labelType: .countryCode)
            getNewValueFromPopup(popupMenuType: .countryCode, currentValue: currentValue, forIndexPath: indexPath)
        }
    }
    
    func textFieldDidChange(_ value: EditContactTextFieldType, indexPath: IndexPath?) {
        viewModel.textFieldDidChange(value, indexPath: indexPath, tableView: tableView)
        setSaveButton()
    }
}

extension EditContactVC: ImagePickerDelegate {
    func didSelect(image: UIImage?, indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        viewModel.setImageInCell(tableView: tableView, atIndexPath: indexPath, image: image) { [weak self] saveButtonVisible in
            guard let self = self else { return }
            self.saveButton.isEnabled = saveButtonVisible
        }
    }
    
    func removeImage(_ indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        viewModel.removeImageInCell(tableView: tableView, atIndexPath: indexPath)
        setSaveButton()
    }
}

extension EditContactVC: PopupMenuDelegate {
    func getNewValueFromPopup(popupMenuType: PopupMenuType, currentValue: String?, forIndexPath: IndexPath?) {
        guard let popupMenu = Storyboard.contactDetails.controller(withClass: PopupMenuVC.self) else { return }
        popupMenu.delegate = self
        popupMenu.viewModel = PopupMenuViewModel(popupMenuType: popupMenuType, currentValue: currentValue, indexPath: forIndexPath)
        self.present(popupMenu, animated: true, completion: nil)
    }
    
    func returnNewValueFromPopup(newValue: String?, for labelType: PopupMenuType, forIndexPath: IndexPath?) {
        viewModel.setNewLabel(tableView, newValue: newValue, for: labelType, forIndexPath: forIndexPath)
        setSaveButton()
    }
}

extension EditContactVC {
    private func setSaveButton() {
        saveButton.isEnabled = viewModel.saveButtonIsEnabled()
    }
}
