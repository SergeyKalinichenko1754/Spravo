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
    @IBOutlet weak var tableViewTop: NSLayoutConstraint!
    @IBOutlet weak var fetchContactsButtonInTableView: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    @IBOutlet weak var topViewLabelDistanceToTop: NSLayoutConstraint!
    
    var viewModel: ContactsViewModel!
    private let extraHeight: CGFloat = UIScreen.main.bounds.size.height > 750 ? 30 : 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupTableView()
        setupTopView()
        setupSearchBar()
        localizeScreen()
        getContacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    private func setup() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = RGBColor(33, 49, 205)
    }
    
    private func localizeScreen() {
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
                        headerView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: (contactsUpload ? 80 : 180 + self.extraHeight))
                        self.fetchContactsButtonInTableView.isHidden = contactsUpload
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func filterButtonTaped(_ sender: UIBarButtonItem) {
        var title = NSLocalizedString("Contacts.SortBy", comment: "Title: Sort by")
        let sortVC = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        for sortOpt in SortContactsBy.allCases {
            sortVC.addAction(UIAlertAction(title: sortOpt.localizedString(), style: .default, handler: { [weak self, sortOpt] (alert: UIAlertAction!) -> Void in
                guard let self = self else { return }
                self.sortContacts(sortOpt)
            }))
        }
        title = NSLocalizedString("Contacts.SortBy.Cancel", comment: "Title for Cancel (Sort by)")
        sortVC.addAction(UIAlertAction(title: title, style: .cancel, handler: nil))
        if let popoverController = sortVC.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        self.present(sortVC, animated: true, completion: nil)
    }
    
    func sortContacts(_ by: SortContactsBy) {
        viewModel.sortContactsBy(by: by, searchText: searchBar.text)
        tableView.reloadData()
    }
    
    @IBAction func addButtonTaped(_ sender: UIBarButtonItem) {
        //TODO(Serhii K) fix in next iterrations
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
    
    private func setupTableView() {
        viewModel.registerCells(for: tableView)
        tableViewTop.constant = CGFloat(70 + extraHeight)
        tableView.tableFooterView = UIView()
        tableView.separatorInset.left = 10
        tableView.separatorInset.right = 10
        fetchContactsButtonInTableView.setTitleColor(RGBColor(33, 49, 205), for: .normal)
    }
    
    private func setupTopView() {
        topViewHeight.constant = 150 + extraHeight
        topViewLabelDistanceToTop.constant = 70 + extraHeight
        topView.alpha = 0.95
        topView.backgroundColor = RGBColor(247, 247, 247)
        topView.addBorder(.bottom, color: RGBColor(210, 210, 210), thickness: 1)
    }
}

extension ContactsVC: UISearchBarDelegate {
    private func setupSearchBar() {
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
        searchBar.resignFirstResponder()
        let topViewDefaultHeight: CGFloat = 150
        let pointMinObserveOffset: CGFloat = -35
        let offsetY = -scrollView.contentOffset.y
        if offsetY > pointMinObserveOffset {
            topViewHeight.constant = topViewDefaultHeight + extraHeight + offsetY
        } else if topViewHeight.constant > topViewDefaultHeight + pointMinObserveOffset + extraHeight {
            topViewHeight.constant = topViewDefaultHeight + pointMinObserveOffset + extraHeight
        }
        if offsetY < pointMinObserveOffset + 13 && navigationItem.title?.count == 0 {
            navigationItem.title = NSLocalizedString("Contacts.Title", comment: "Title of contacts screen")
        } else if offsetY > pointMinObserveOffset + 13 && navigationItem.title?.count != 0 {
            navigationItem.title = ""
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.showContactDetails(indexPath)
    }
}
