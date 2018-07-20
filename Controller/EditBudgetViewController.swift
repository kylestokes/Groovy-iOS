//
//  EditBudgetViewController.swift
//  groovy
//
//  Created by Kyle Stokes on 7/15/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit
import Firebase

class EditBudgetViewController: UIViewController {
    
    // MARK: - Properties
    
    var databaseReference: DatabaseReference!
    var budget: Budget!
    
    // MARK: - Outlets
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var amount: UITextField!
    
    // MARK: - Actions
    
    @IBAction func dismiss(_ sender: Any) {
        resignAndDismiss()
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        save()
    }
    
    @IBAction func reset(_ sender: UIBarButtonItem) {
        showResetAlert()
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configName()
        configAmount()
    }
    
    func configName() {
        name.text = budget.name!
        name.delegate = self
        name.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        name.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    func configAmount() {
        var budgetAmountFormatted = formatAsCurrency(budget.setAmount!)
        budgetAmountFormatted = budgetAmountFormatted.replacingOccurrences(of: "$", with: "")
        amount.text = budgetAmountFormatted.replacingOccurrences(of: ",", with: "")
        amount.delegate = self
        amount.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        amount.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
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
        let textFieldsHaveValue = (amount.text?.count)! > 0 && (name.text?.count)! > 0 ? true : false
        return textFieldsHaveValue
    }
    
    func resignAndDismiss() {
        amount.resignFirstResponder()
        name.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    func showResetAlert() {
        let alert = UIAlertController(title: "Reset \(name.text!)", message: "Resetting \(name.text!) will remove all purchase history and set spending back to $0.00", preferredStyle: .actionSheet)
        
        alert.view.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        
        let deleteAction = UIAlertAction(title: "Reset", style: .default, handler: { (delete) in
            self.resetBudget()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func resetBudget() {
        // TODO
        
    }
    
    @objc func save() {
        // Save in Firebase and then dismiss
        databaseReference.child("budgets").child("\(budget.id!)").child("name").setValue(name.text!) { (error, ref) in
            if error == nil {
                self.databaseReference.child("budgets").child("\(self.budget.id!)").child("setAmount").setValue(Double(self.amount.text!)) { (error, ref) in
                    if error == nil {
                        self.resignAndDismiss()
                    }
                }
            }
        }
    }
    
    @objc func textFieldDidChange() {
        saveButton.isEnabled = textFieldsHaveValues()
    }
    
    // Close keyboard when tapping outside of keyboard
    // https://medium.com/@KaushElsewhere/how-to-dismiss-keyboard-in-a-view-controller-of-ios-3b1bfe973ad1
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension EditBudgetViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if name.isEditing {
            amount.becomeFirstResponder()
        } else {
            if textFieldsHaveValues() {
                save()
            }
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
