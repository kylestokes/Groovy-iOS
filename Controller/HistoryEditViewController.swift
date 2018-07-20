//
//  HistoryEditViewController.swift
//  groovy
//
//  Created by Kyle Stokes on 7/17/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit
import Firebase

class HistoryEditViewController: UIViewController {
    
    // MARK: - Properties
    
    var databaseReference: DatabaseReference!
    var budget: Budget!
    var purchase: String!
    var saveButton: UIBarButtonItem!
    
    // MARK: - Outlets
    
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var note: UITextField!
    
    // MARK: // Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configAmountField()
        configNoteField()
        configNavBar()
    }
    
    func configNavBar() {
        self.title = "Edit"
        saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
        saveButton.isEnabled = textFieldsHaveValues()
        navigationItem.rightBarButtonItem = saveButton
    }
    
    func configAmountField() {
        let purchaseAmount = Double(purchase.split(separator: ":")[0])
        let purchaseAmountFormatted = formatAsCurrency(purchaseAmount!)
        amount.text = purchaseAmountFormatted.replacingOccurrences(of: "$", with: "")
        amount.text = amount.text?.replacingOccurrences(of: ",", with: "")
        amount.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        amount.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        amount.becomeFirstResponder()
        amount.delegate = self
    }
    
    func configNoteField() {
        let noteText = String(purchase.split(separator: ":")[1])
        note.text = noteText
        note.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        note.delegate = self
        note.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
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
    
    func textFieldsHaveValues() -> Bool {
        let textFieldsHaveValue = (amount.text?.count)! > 0 && (note.text?.count)! > 0 ? true : false
        return textFieldsHaveValue
    }
    
    @objc func save() {
        let indexOfEditedPurchase = budget.history?.index(of: purchase)
        budget.history![indexOfEditedPurchase!] = "\(amount.text!):\(note.text!)"
        
        // Save in Firebase and then pop to history
        databaseReference.child("budgets").child("\(budget.id!)").child("history").setValue(budget.history!) { (error, ref) in
            if error == nil {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func textFieldDidChange() {
        saveButton.isEnabled = textFieldsHaveValues()
    }
}

extension HistoryEditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textFieldsHaveValues() {
            save()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Only allow numbers and 1 decimal in amount text field
        // https://stackoverflow.com/a/48093890
        if textField.keyboardType == .decimalPad {
            let s = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
            guard !s.isEmpty else { return true }
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .none
            return numberFormatter.number(from: s)?.intValue != nil
        } else {
            return true
        }
    }
}
