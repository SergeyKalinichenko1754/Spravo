//
//  ContactDetailsVC.swift
//  Spravo
//
//  Created by Onix on 11/12/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import MessageUI

class ContactDetailsVC: UIViewController {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var imageViewInTopView: UIImageView!
    @IBOutlet weak var imageViewTopDistance: NSLayoutConstraint!
    @IBOutlet weak var nameLabelInTopView: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    @IBOutlet weak var editContactButton: UIBarButtonItem!
    
    var viewModel: ContactDetailsViewModelType!
    private let extraHeight: CGFloat = max(UIScreen.main.bounds.size.height, UIScreen.main.bounds.size.width) > 750 ? 30 : 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopView()
        setupNavigationBar()
        setupTableView()
        setupTopImage()
        localizeScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !viewModel.contactExist() {
            viewModel.dismissVC()
            return
        }
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        setupProfileImage()
        tableView.reloadData()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        topView.backgroundColor = DefaultColors.navigationBarBackgroundColor
    }
    
    private func setupTopView() {
        setupProfileImage()
        imageViewTopDistance.constant = max(UIScreen.main.bounds.size.height, UIScreen.main.bounds.size.width) > 750 ? 35 : 17
        topViewHeight.constant = 180 + extraHeight
        nameLabelInTopView.text = viewModel.getFullName()
    }
    
    private func setupProfileImage() {
        viewModel.getProfileImage { image in
            updateUIonMainThread { [weak self] in
                guard let self = self else { return}
                self.imageViewInTopView.image = image
            }
        }
    }
    
    private func setupTopImage() {
        imageViewInTopView.layer.cornerRadius = imageViewInTopView.frame.width / 2
        imageViewInTopView.layer.masksToBounds = true
    }
    
    private func localizeScreen() {
        editContactButton.title = NSLocalizedString("Contacts.Edit", comment: "Caption of edit button")
    }
    
    @IBAction func backToContactsButtonTaped(_ sender: UIBarButtonItem) {
        viewModel.backTaped()
    }
    
    @IBAction func editContactButtonTaped(_ sender: UIBarButtonItem) {
        viewModel.editContact()
    }
}

extension ContactDetailsVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.getNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRows(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = viewModel.cellForTableView(tableView: tableView, atIndexPath: indexPath, smsButtonDelegate: self)
        return cell
    }
    
    private func setupTableView() {
        viewModel.registerCells(for: tableView)
        tableView.tableFooterView = UIView()
        if let headerView = self.tableView?.tableHeaderView {
            headerView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: 80 + self.extraHeight)
        }
        tableView.separatorInset.left = 10
        tableView.separatorInset.right = 10
        tableView.rowHeight = UITableView.automaticDimension
    }
}

extension ContactDetailsVC: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let topViewDefaultHeight: CGFloat = 180
        let topViewMinHeight: CGFloat = 100
        let offsetY = -scrollView.contentOffset.y
        topViewHeight.constant = max(topViewMinHeight + extraHeight, topViewDefaultHeight + extraHeight + offsetY)
        setupTopImage()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectRowAt(tableView, indexPath: indexPath, rootVC: self) { error in
            guard let error = error else { return }
            updateUIonMainThread {
                AlertHelper.showAlert(error)
            }
        }
    }
}

extension ContactDetailsVC: SendSMSButtonDelegate, MFMessageComposeViewControllerDelegate {
    func sendSMS(_ to: String) {
        viewModel.sendSMS(to, inVC: self)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .sent:
            debugPrint("Sent")
        default: break
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
