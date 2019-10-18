//
//  FetchPhoneContactsVC.swift
//  Spravo
//
//  Created by Onix on 10/10/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class FetchPhoneContactsVC: UITableViewController {
    @IBOutlet weak var importContactsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var viewModel: FetchPhoneContactsViewModelType!
    let popupVC = PopupVC()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    func setupScreen() {
        importContactsLabel.text = NSLocalizedString("ImportPhoneContacts.TopLabel", comment: "Text on label with name of import existing contacts process")
        descriptionLabel.text = NSLocalizedString("ImportPhoneContacts.DescriptionLabel", comment: "Description of import existing contacts process")
        let importButtonCaption = NSLocalizedString("ImportPhoneContacts.ImportButtonCaption", comment: "Name for allow import contacts button")
        importButton.setTitle(importButtonCaption, for: .normal)
        let cancelButtonCaption = NSLocalizedString("ImportPhoneContacts.CancelButtonCaption", comment: "Name for cancel import contacts button")
        cancelButton.setTitle(cancelButtonCaption, for: .normal)
        importButton.layer.cornerRadius = 10
        importButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        importButton.layer.masksToBounds = true
        cancelButton.layer.cornerRadius = 10
        cancelButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner]
        cancelButton.layer.masksToBounds = true
    }
    
    func fetchPhonesContacts() {
        viewModel.fetchPhonesContacts { [weak self] success in
            guard let self = self else { return }
            if success {
                //TODO(Serhii K.) delete DispatchQueue.main.asyncAfter on next stage
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: { [weak self] in
                    guard let self = self else { return }
                    self.popupVC.nextTaskForActivityIndicator()
                    self.syncingContacts()
                })
                return
            }
            self.showSettingsAlert()
        }
    }
    
    func syncingContacts() {
        viewModel.syncingContacts { [weak self] success in
            guard let self = self else { return }
            if success {
                //TODO(Serhii K.) delete DispatchQueue.main.asyncAfter on next stage
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: { [weak self] in
                    guard let self = self else { return }
                    self.popupVC.nextTaskForActivityIndicator()
                    self.viewModel.finishedRequestContacts()
                })
                return
            }
            self.showSettingsAlert()
        }
    }
    
    private func showSettingsAlert() {
        let msg = NSLocalizedString("ImportPhoneContacts.AskForPermission", comment: "Message that the program needs access to the phone contacts")
        let leftButtonCaption = NSLocalizedString("ImportPhoneContacts.AskForPermissionCancelButtonCaption", comment: "Cancel button caption")
        let rightBittonCaption = NSLocalizedString("ImportPhoneContacts.AskForPermissionOpenSettingsButtonCaption", comment: "OpenSettings button caption")
        AlertHelper.showAlert(msg: msg, from: self, leftBtnTitle: leftButtonCaption, rightBtnTitle: rightBittonCaption) { (result) in
            if result {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
        }
    }
    
    @IBAction func tapedImportButton(_ sender: UIButton) {
        let label1 = "Reading contacts"
        let label2 = "Synsing with Spravo"
        self.popupVC.showScreen(vc: self, labels: [label1, label2], showIndicator: true)
        self.fetchPhonesContacts()
    }
    
    @IBAction func tapedCancelButton(_ sender: UIButton) {
        viewModel.finishedRequestContacts()
    }
}

extension FetchPhoneContactsVC: PopupVCDelegate {
    func tapedCancelButtonInPopupVC() {
        viewModel.finishedRequestContacts()
    }
}
