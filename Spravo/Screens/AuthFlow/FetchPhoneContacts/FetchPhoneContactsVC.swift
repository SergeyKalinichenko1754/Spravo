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
    weak var activityController: ActivityScreenVC?
    weak var errorController: ErrorScreenVC?
    
    enum ErrorType {
        case checkInternetConnection
        case syncingContactsfailed
        case other(String)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    override func viewDidLayoutSubviews() {
        tableView.isScrollEnabled = tableView.contentSize.height > tableView.frame.size.height
    }
    
    private func setupScreen() {
        tableView.allowsSelection = false
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
    
    private func fetchPhonesContacts() {
        startActivityScreen()
        viewModel.fetchPhonesContacts { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.stopActivityIndicator()
                self.showErrorScreen(.other(error))
            case .success(false):
                self.stopActivityIndicator()
                self.showSettingsAlert()
            case .success(true):
                self.syncingContacts()
            }
        }
    }
    
    private func syncingContacts() {
        starNextActivityIndicator()
        viewModel.syncingContacts { [weak self] success in
            guard let self = self else { return }
            guard success else {
                self.showSettingsAlert()
                return
            }
            //TODO(Serhii K.) Delete DispatchQueue.main and unrem //self.viewModel.finishedRequestContacts()
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(2)) { [weak self] in
                guard let self = self else { return }
                self.starNextActivityIndicator()
                //self.viewModel.finishedRequestContacts()
            }
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
    
    private func startActivityScreen() {
        activityController = Storyboard.service.controller(withClass: ActivityScreenVC.self)
        guard let activityController = activityController else { return }
        updateUIonMainThread { [weak self] in
            guard let self = self else { return }
            let lb_1 = NSLocalizedString("ImportPhoneContacts.Action_1", comment: "Description first action in fetching contacts")
            let lb_2 = NSLocalizedString("ImportPhoneContacts.Action_2", comment: "Description second action in fetching contacts")
            activityController.labels = [lb_1, lb_2]
            activityController.parentDelegate = self
            self.navigationController?.modalPresentationStyle = .overCurrentContext
            self.navigationController?.present(activityController, animated: true, completion: nil)
        }
    }
    
    private func starNextActivityIndicator() {
        guard let activityController = activityController else { return }
        updateUIonMainThread {
            activityController.starNextActivityIndicator()
        }
    }
    
    private func stopActivityIndicator() {
        guard let activityController = activityController else { return }
        updateUIonMainThread {
            activityController.stopActivityIndicator()
        }
    }

    private func showErrorScreen(_ errorType: ErrorType) {
        errorController = Storyboard.service.controller(withClass: ErrorScreenVC.self)
        guard let errorController = errorController else { return }
        updateUIonMainThread { [weak self] in
            guard let self = self else { return }
            switch errorType {
            case .checkInternetConnection:
                errorController.image = UIImage(named: "Disconnected")
                errorController.text = NSLocalizedString("ImportPhoneContacts.ErrorInternetConnection", comment: "Request to check internet connection")
            case .syncingContactsfailed:
                errorController.text = NSLocalizedString("ImportPhoneContacts.ErrorSyncingContactsFailed", comment: "Message about syncing contacts failed") + ": " + supportEmail
            case .other(let error):
                errorController.text = error
            }
            self.navigationController?.modalPresentationStyle = .overCurrentContext
            self.navigationController?.present(errorController, animated: true, completion: nil)
        }
    }
    
    @IBAction func tapedImportButton(_ sender: UIButton) {
        self.fetchPhonesContacts()
    }
    
    @IBAction func tapedCancelButton(_ sender: UIButton) {
        viewModel.finishedRequestContacts()
    }
}

extension FetchPhoneContactsVC: ActivityScreenDelegate {
    func userInterruptedAction() {
        //TODO(Serhii K.) Delete showErrorScreen unrem next str (//viewModel.userInterruptedAction())
        showErrorScreen(.checkInternetConnection)
        //viewModel.userInterruptedAction()
    }
}
