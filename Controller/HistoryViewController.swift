//
//  HistoryViewController.swift
//  groovy
//
//  Created by Kyle Stokes on 7/15/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {
    
    // MARK: - Properties
    
    var budget: Budget!
    var userEmail: String!
    var budgetHistory: [String]!
    var userDate: [String]!
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Actions
    
    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configBudgetHistory()
        configUserDate()
        configTableView()
    }
    
    func configTableView() {
        tableView.tableFooterView = UIView()
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
        let noteSubstring = history.split(separator: ":")[1]
        if noteSubstring.isEmpty {
            let note = ""
            return note
        } else {
            return String(noteSubstring)
        }
    }
    
    func deleteHistory(purchase: String) {
        print(purchase)
    }
    
    func editHistory(purchase: String) {
        print(purchase)
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
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if budgetHistory == nil {
            tableView.isHidden = true
            return 0
        } else {
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
            let noteSubstring = historyItemToDelete.split(separator: ":")[1]
            let note = String(noteSubstring)
            let deleteMessage = note == "" ? "Are you sure you want to delete this purchase?" : "Are you sure you want to delete '\(note)'?"
            
            let alert = UIAlertController(title: "Delete \(amountCurrency) Purchase", message: "\(deleteMessage)", preferredStyle: .actionSheet)

            alert.view.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)

            let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { (delete) in
                self.deleteHistory(purchase: historyItemToDelete)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
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
        editButton.backgroundColor = UIColor.lightGray
        
        return [deleteButton, editButton]
    }
}
