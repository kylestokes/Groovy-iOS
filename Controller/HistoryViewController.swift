//
//  HistoryViewController.swift
//  groovy
//
//  Created by Kyle Stokes on 7/15/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit
import Firebase

class HistoryViewController: UIViewController {
    
    // MARK: - Properties
    
    var databaseReference: DatabaseReference!
    var budget: Budget!
    var userEmail: String!
    var budgetHistory: [String]!
    var userDate: [String]!
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getBudgetFromFirebase()
        configNavBar()
        configBudgetHistory()
        configUserDate()
        configTableView()
        updateBudgetSpent()
        updateBudgetAmountLeft()
    }
    
    func configNavBar() {
        self.title = "History"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "close"), style: .done, target: self, action: #selector(dismiss))
        navigationController?.navigationBar.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
    }
    
    @objc func dismiss(_ sender: UIBarButtonItem) {
        updateBudgetSpent()
        updateBudgetAmountLeft()
        firebaseSave()
    }
    
    func configTableView() {
        tableView.tableFooterView = UIView()
        tableView.reloadData()
    }
    
    func configBudgetHistory() {
        budgetHistory = budget.history
        // Remove 'none:none' in budget history
        budgetHistory.remove(at: 0)
    }
    
    func configUserDate() {
        userDate = budget.userDate
        // Remove 'none:none' in budget 'userDate'
        userDate.remove(at: 0)
    }
    
    func getDateStringFor(_ userDate: String) -> String {
        let dateForMillisecondsSince1970 = String(userDate.split(separator: ":")[1])
        let dateForMillsecondsSince1970Double = Double(dateForMillisecondsSince1970)
        let date = Date(timeIntervalSince1970: dateForMillsecondsSince1970Double!/1000.0)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        return dateFormatter.string(from: date)
    }
    
    func getUserStringFor(_ userDate: String) -> String {
        let userEmail = String(userDate.split(separator: ":")[0])
        let user = String(userEmail.split(separator: "@")[0])
        if userEmail == self.userEmail {
            return "\(user) (Me)"
        } else {
            return user
        }
    }
    
    func getAmountFor(_ history: String) -> String {
        let amount = Double(history.split(separator: ":")[0])
        let amountAsCurrency = formatAsCurrency(amount!)
        return amountAsCurrency
    }
    
    func getNoteFor(_ history: String) -> String {
        // https://stackoverflow.com/a/35512668
        if history.split(separator: ":").indices.contains(1) {
            let noteSubstring = history.split(separator: ":")[1]
            return String(noteSubstring)
        } else {
            return ""
        }
    }
    
    func deleteHistory(purchase: String) {
        let historyPurchaseToDelete = budgetHistory.index(of: purchase)
        budgetHistory.remove(at: historyPurchaseToDelete!)
        userDate.remove(at: historyPurchaseToDelete!)
        tableView.reloadData()
    }
    
    func editHistory(purchase: String) {
        let historyEditViewController = storyboard?.instantiateViewController(withIdentifier: "historyEdit") as! HistoryEditViewController
        historyEditViewController.budget = budget
        historyEditViewController.purchase = purchase
        historyEditViewController.databaseReference = databaseReference
        navigationController?.pushViewController(historyEditViewController, animated: true)
    }
    
    func updateBudgetSpent() {
        var newAmountSpent: Double = 0
        for amount in budgetHistory {
            let amountDouble = Double(amount.split(separator: ":")[0])
            newAmountSpent += amountDouble!
        }
        budget.spent = newAmountSpent
    }
    
    func updateBudgetAmountLeft() {
        budget.left = budget.setAmount! - budget.spent!
    }
    
    func firebaseSave() {
        var userDateFirebase = userDate!
        userDateFirebase.insert("none:none", at: 0)
        var historyFirebase = budgetHistory!
        historyFirebase.insert("none:none", at: 0)
        var budgetDictionary: [String:Any] = [:]
        budgetDictionary["name"] = budget.name
        budgetDictionary["createdBy"] = budget.createdBy
        budgetDictionary["hiddenFrom"] = budget.hiddenFrom
        budgetDictionary["history"] = historyFirebase
        budgetDictionary["isShared"] = budget.isShared
        budgetDictionary["left"] = budget.left
        budgetDictionary["setAmount"] = budget.setAmount
        budgetDictionary["sharedWith"] = budget.sharedWith
        budgetDictionary["spent"] = budget.spent
        budgetDictionary["userDate"] = userDateFirebase
        databaseReference.child("budgets").child("\(budget.id!)").setValue(budgetDictionary as NSDictionary) { (error, ref) in
            if error == nil {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func formatAsCurrency(_ number: Double) -> String {
        let formatter = NumberFormatter()
        var currency: String = ""
        formatter.numberStyle = .currency
        if let formattedCurrencyAmount = formatter.string(from: number as NSNumber) {
            currency = "\(formattedCurrencyAmount)"
        }
        return currency
    }
    
    func getBudgetFromFirebase() {
        databaseReference.child("budgets").child("\(budget.id!)").observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let uid = snapshot.key
                let budget = Budget.from(firebase: dictionary, uid: uid)
                self.budget = budget
            }
        })
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if budgetHistory.count == 0 {
            tableView.isHidden = true
            return 0
        } else {
            tableView.isHidden = false
            return budgetHistory.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryCell
        
        // Get 'date' and 'user' from budget's 'userDate'
        let userDate = self.userDate[indexPath.row]
        cell.date.text = getDateStringFor(userDate)
        cell.email.text = getUserStringFor(userDate)
        
        // Get 'amount' and 'note' from budget's 'history'
        let history = self.budgetHistory[indexPath.row]
        cell.amount.text = getAmountFor(history)
        cell.note.text = getNoteFor(history)
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let historyItemToDelete = budgetHistory[indexPath.row]
            let amount = Double(historyItemToDelete.split(separator: ":")[0])
            let amountCurrency = formatAsCurrency(amount!)
            var noteSubstring = ""
            // https://stackoverflow.com/a/35512668
            if historyItemToDelete.split(separator: ":").indices.contains(1) {
                noteSubstring = String(historyItemToDelete.split(separator: ":")[1])
            }
            let note = noteSubstring
            let deleteMessage = note == "" ? "Are you sure you want to delete this purchase?" : "Are you sure you want to delete '\(note)'?"
            
            let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { (delete) in
                self.deleteHistory(purchase: historyItemToDelete)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let actions = [deleteAction, cancelAction]
            showActionSheetAlert(title: "Delete \(amountCurrency) Purchase", message: "\(deleteMessage)", actions: actions)
        } else {
            let historyItemToEdit = budgetHistory[indexPath.row]
            self.editHistory(purchase: historyItemToEdit)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            self.tableView.dataSource?.tableView!(self.tableView, commit: .delete, forRowAt: indexPath)
            return
        }
        deleteButton.backgroundColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        
        let editButton = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in
            self.tableView.dataSource?.tableView!(self.tableView, commit: .none, forRowAt: indexPath)
            return
        }
        editButton.backgroundColor = UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.0)
        
        return [deleteButton, editButton]
    }
}
