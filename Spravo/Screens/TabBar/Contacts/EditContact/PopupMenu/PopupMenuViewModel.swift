//
//  PopupMenuViewModel.swift
//  Spravo
//
//  Created by Onix on 11/29/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

enum PopupMenuType: String {
    case phoneLabel
    case emailLabel
    case addressLabel
    case countryCode
}

protocol PopupMenuViewModelType {
    func registerCells(for tableView: UITableView)
    func getNumberOfSections() -> Int
    func getNumberOfRows(section: Int) -> Int
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath, delegate: AddNewLabelInTextFieldPopupMenuDelegate) -> UITableViewCell
    func getCurrentValue() -> String?
    func setNewValue(_ selectedIndexPath: IndexPath)
    func getForIndexPath() -> IndexPath?
    func getPopupMenuType() -> PopupMenuType
    func addNewLabel(_ tableView: UITableView, value: String)
}

class PopupMenuViewModel: PopupMenuViewModelType {
    private var popupMenuType: PopupMenuType
    private var currentValue: String?
    private var indexPath: IndexPath?
    private var popupMenuArray: [(value: String?, localized: String?)] = []
    private var customPopupMenuArray: [String]?
    private var keyForUserDefaultStore: String?
    
    init(popupMenuType: PopupMenuType, currentValue: String?, indexPath: IndexPath?) {
        self.popupMenuType = popupMenuType
        self.currentValue = currentValue
        self.indexPath = indexPath
        getData()
    }
    
    func registerCells(for tableView: UITableView) {
        tableView.register(UINib(nibName: PopupMenuLabelCell.identifier, bundle: nil), forCellReuseIdentifier: PopupMenuLabelCell.identifier)
        tableView.register(UINib(nibName: PopupMenuAddNewLabelCell.identifier, bundle: nil), forCellReuseIdentifier: PopupMenuAddNewLabelCell.identifier)
    }
    
    func getNumberOfSections() -> Int {
        return 2
    }
    
    private func getData() {
        switch popupMenuType {
        case .phoneLabel:
            popupMenuArray = PhoneLabelString.allCases.map { (value: $0.rawValue, localized: $0.rawValue.localized) }
            keyForUserDefaultStore = PhoneLabelString.keyForUserDefaultStore
        case .emailLabel:
            popupMenuArray = EmailLabelString.allCases.map { (value: $0.rawValue, localized: $0.rawValue.localized) }
            keyForUserDefaultStore = EmailLabelString.keyForUserDefaultStore
        case .addressLabel:
            popupMenuArray = AddressLabelString.allCases.map { (value: $0.rawValue, localized: $0.rawValue.localized) }
            keyForUserDefaultStore = AddressLabelString.keyForUserDefaultStore
        case .countryCode:
            for code in Locale.isoRegionCodes as [String] {
                if let name = Locale.autoupdatingCurrent.localizedString(forRegionCode: code) {
                    popupMenuArray.append((value: code, localized: name))
                }
            }
        }
        getCustomData()
    }
    
    func getNumberOfRows(section: Int) -> Int {
        return section == 0 ? popupMenuArray.count : (customPopupMenuArray?.count ?? -1) + 1
    }
    
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath, delegate: AddNewLabelInTextFieldPopupMenuDelegate) -> UITableViewCell {
        switch indexPath {
        case let index where index.section == 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PopupMenuLabelCell.identifier, for: indexPath) as? PopupMenuLabelCell else { return UITableViewCell() }
            let element = popupMenuArray[indexPath.row]
            cell.labelMark.text = element.localized
            cell.accessoryType = element.value == currentValue ? .checkmark : .none
            return cell
        case let index where index.section == 1 && index.row < (customPopupMenuArray?.count ?? 0):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PopupMenuLabelCell.identifier, for: indexPath) as? PopupMenuLabelCell else { return UITableViewCell() }
            let element = customPopupMenuArray?[indexPath.row]
            cell.labelMark.text = element
            cell.accessoryType = element == currentValue ? .checkmark : .none
            return cell
        case let index where index.section == 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PopupMenuAddNewLabelCell.identifier, for: indexPath) as? PopupMenuAddNewLabelCell else { return UITableViewCell() }
            let title = NSLocalizedString("EditContacts.AddOwnLabel", comment: "Caption for add own label button")
            cell.addNewLabelButton.setTitle(title, for: .normal)
            cell.delegate = delegate
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func getCurrentValue() -> String? {
        return currentValue
    }
    
    func setNewValue(_ forIndexPath: IndexPath) {
        currentValue = forIndexPath.section == 0 ? popupMenuArray[forIndexPath.row].value : customPopupMenuArray?[forIndexPath.row]
    }
    
    func getForIndexPath() -> IndexPath? {
        return indexPath
    }
    
    func getPopupMenuType() -> PopupMenuType {
        return popupMenuType
    }
    
    private func getCustomData() {
        guard let key = keyForUserDefaultStore else { return }
        if let array = UserDefaults.standard.object(forKey: key) as? [String] {
            customPopupMenuArray = array
        } else {
            customPopupMenuArray = []
        }
    }
    
    private func saveCustomMenu() {
        guard let key = keyForUserDefaultStore else { return }
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            UserDefaults.standard.set(self.customPopupMenuArray, forKey: key)
        }
    }
    
    func addNewLabel(_ tableView: UITableView, value: String) {
        customPopupMenuArray?.append(value)
        saveCustomMenu()
        currentValue = value
    }
    
    func trailingSwipeActions(_ tableView: UITableView, indexPath: IndexPath)-> UISwipeActionsConfiguration? {
        guard indexPath.section == 1 && indexPath.row < (customPopupMenuArray?.count ?? 0) else { return UISwipeActionsConfiguration(actions: []) }
        let title = NSLocalizedString("EditContacts.DeleteCell", comment: "title for delete cell action")
        let act = UIContextualAction(style: .destructive, title: title) { [weak self] (action, view, completion) in
            guard let self = self else { return }
            self.customPopupMenuArray?.remove(at: indexPath.row)
            self.saveCustomMenu()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [act])
    }
}
