//
//  SpentMoneyViewController.swift
//  groovy
//
//  Created by Kyle Stokes on 7/15/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit
import Firebase
import DeviceKit

class SpentMoneyViewController: UIViewController {
    
    // MARK: - Properties
    
    var databaseReference: DatabaseReference!
    var budget: Budget!
    var userEmail: String!
    
    // MARK: - Outlets
    
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var note: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: - Actions
    
    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        resignAndDismiss()
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        addPurchase()
    }
    
    // MARK: - Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configAmountTextField()
        configNoteTextField()
    }
    
    func configAmountTextField() {
        amount.delegate = self
        amount.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        amount.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        amount.becomeFirstResponder()
    }
    
    func configNoteTextField() {
        let device = Device()
        note.delegate = self
        note.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        note.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        if device.isOneOf(iPadsThatNeedAdjusting.noniPadPro12InchDevices) {
            note.autocorrectionType = .no
        }
    }
    
    func addPurchase() {
        let noteText = note.text == nil ? "" : note.text
        let newHistoryPurchase = "\(amount.text!):\(noteText!)"
        // https://stackoverflow.com/a/40135172
        let date = String((Date().timeIntervalSince1970 * 1000))
        let newUserDate = "\(userEmail!):\(date)"
        budget.history?.append(newHistoryPurchase)
        budget.userDate?.append(newUserDate)
        budget.spent! += Double(amount.text!)!
        budget.left = budget.setAmount! - budget.spent!
        var budgetDictionary: [String:Any] = [:]
        budgetDictionary["name"] = budget.name
        budgetDictionary["createdBy"] = budget.createdBy
        budgetDictionary["hiddenFrom"] = budget.hiddenFrom
        budgetDictionary["history"] = budget.history
        budgetDictionary["isShared"] = budget.isShared
        budgetDictionary["left"] = budget.left
        budgetDictionary["setAmount"] = budget.setAmount
        budgetDictionary["sharedWith"] = budget.sharedWith
        budgetDictionary["spent"] = budget.spent
        budgetDictionary["userDate"] = budget.userDate
        databaseReference.child("budgets").child("\(budget.id!)").setValue(budgetDictionary as NSDictionary)
        Haptics.doSuccessHapticFeedback()
        self.resignAndDismiss()
    }
    
    func resignAndDismiss() {
        amount.resignFirstResponder()
        note.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func textFieldDidChange() {
        saveButton.isEnabled = amountHasValue()
    }
    
    func amountHasValue() -> Bool {
        if amount.hasText {
            let isAmountGreaterThanEqualOneCent = Double(amount.text!)! >= 0.01 ? true : false
            let isAmountGreaterThanFiveMillion = Double(amount.text!)! > 5000000 ? true : false
            let amountHasValue = (amount.text?.count)! > 0  && isAmountGreaterThanEqualOneCent && !isAmountGreaterThanFiveMillion ? true : false
            return amountHasValue
        } else {
            return false
        }
    }
    
    // Close keyboard when tapping outside of keyboard
    // https://medium.com/@KaushElsewhere/how-to-dismiss-keyboard-in-a-view-controller-of-ios-3b1bfe973ad1
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension SpentMoneyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if amountHasValue() { addPurchase() }
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
