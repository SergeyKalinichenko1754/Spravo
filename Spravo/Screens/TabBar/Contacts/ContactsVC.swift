//
//  ContactsVC.swift
//  Spravo
//
//  Created by Onix on 10/30/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class ContactsVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fetchContactsButtonInTableView: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    
    var viewModel: ContactsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        localizeScreen()
        setupTableView()
        setupSearchBar()
        getContacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    private func setup() {
        viewModel.registerCells(for: tableView)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    fileprivate func localizeScreen() {
        topViewLabel.text = NSLocalizedString("Contacts.Title", comment: "Title of contacts screen")
        let btnCapt = NSLocalizedString("Contacts.ImportButtonCaption", comment: "Caption for import contacts button")
        fetchContactsButtonInTableView.setTitle(btnCapt, for: .normal)
    }
    
    private func getContacts() {
        updateUIonMainThread {
            HUDRenderer.showHUD()
        }
        self.viewModel.getContacts { (result) in
            updateUIonMainThread { [weak self] in
                guard let self = self else { return }
                HUDRenderer.hideHUD()
                switch result {
                case .failure(let error):
                    AlertHelper.showAlert(error)
                case .success:
                    if let headerView = self.tableView?.tableHeaderView {
                        let contactsUpload = self.viewModel.getNumberOfSections() != 0
                        headerView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: (contactsUpload ? 80 : 180))
                        self.fetchContactsButtonInTableView.isHidden = contactsUpload
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func addButtonTaped(_ sender: UIBarButtonItem) {
        debugPrint("Add Contacts")
    }
    
    @IBAction func fetchContactsButtonInTableViewTaped(_ sender: UIButton) {
        viewModel.startFetchPhoneContacts()
    }
    
}

extension ContactsVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.getNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.getTitleForHeaderInSection(section: section)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return viewModel.getSectionIndexTitles()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRows(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = viewModel.cellForTableView(tableView: tableView, atIndexPath: indexPath)
        return cell
    }
    
    func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        tableView.separatorInset.left = 10
        tableView.separatorInset.right = 10
    }
}

extension ContactsVC: UISearchBarDelegate {
    private func setupSearchBar() {
        topView.alpha = 0.95
        topView.backgroundColor = RGBColor(247, 247, 247)
        topView.addBorder(.bottom, color: RGBColor(210, 210, 210), thickness: 1)
        fetchContactsButtonInTableView.setTitleColor(RGBColor(33, 49, 205), for: .normal)
        searchBar.delegate = self
        searchBar.showsScopeBar = false
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = RGBColor(247, 247, 247).cgColor
        searchBar.barTintColor = RGBAColor(247, 247, 247, 1)
        if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField {
            textFieldInsideSearchBar.backgroundColor = RGBAColor(240, 240, 240, 1)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(searchText: searchText)
        updateUIonMainThread { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
}

extension ContactsVC: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = -scrollView.contentOffset.y
        if offsetY > -35 {
            topViewHeight.constant = 150 + offsetY
        } else if topViewHeight.constant > 115 {
            topViewHeight.constant = 115
        }
        if offsetY < -22 && navigationItem.title?.count == 0 {
            navigationItem.title = NSLocalizedString("Contacts.Title", comment: "Title of contacts screen")
        } else if offsetY > -22 && navigationItem.title?.count != 0 {
            navigationItem.title = ""
        }
    }
}

