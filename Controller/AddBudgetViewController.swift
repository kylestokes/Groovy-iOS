//
//  AddBudgetViewController.swift
//  groovy
//
//  Created by Kyle Stokes on 7/11/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit
import Firebase
import DeviceKit

class AddBudgetViewController: UIViewController {
    
    // MARK: Properties
    
    var databaseReference: DatabaseReference!
    var userEmail: String!
    
    // MARK: - Outlets
    
    @IBOutlet weak var budgetName: UITextField!
    @IBOutlet weak var budgetAmount: UITextField!
    @IBOutlet weak var save: UIBarButtonItem!
    
    // MARK: - Actions
    
    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveBudget(_ sender: UIBarButtonItem) {
        addNewBudgetOnSave()
    }
    
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configTextFields()
        save.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if budgetName.isFirstResponder {
            budgetName.resignFirstResponder()
        } else {
            budgetAmount.resignFirstResponder()
        }
    }
    
    func configTextFields() {
        let device = Device()
        budgetName.becomeFirstResponder()
        budgetName.delegate = self
        if device.isOneOf(iPadsThatNeedAdjusting.noniPadPro12InchDevices) {
            budgetName.autocorrectionType = .no
        }
        budgetName.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        budgetAmount.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        budgetAmount.delegate = self
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if budgetName.hasText && budgetAmount.hasText {
            let isAmountGreaterThanEqualOneCent = Double(budgetAmount.text!)! >= 0.01 ? true : false
            let isAmountGreaterThanFiveMillion = Double(budgetAmount.text!)! > 5000000 ? true : false
            save.isEnabled = isAmountGreaterThanEqualOneCent && !isAmountGreaterThanFiveMillion ? true : false
        } else {
            save.isEnabled = false
        }
    }
    
    func addNewBudgetOnSave() {
        var budgetData: [String: Any] = [:]
        budgetData["name"] = budgetName.text!
        budgetData["setAmount"] = Double(budgetAmount.text!)
        budgetData["spent"] = 0
        budgetData["left"] = Double(budgetAmount.text!)
        budgetData["createdBy"] = userEmail
        budgetData["sharedWith"] = ["none"]
        budgetData["hiddenFrom"] = ["none"]
        budgetData["isShared"] = false
        budgetData["history"] = ["none:none"]
        budgetData["userDate"] = ["none:none"]
        databaseReference.child("budgets").childByAutoId().setValue(budgetData)
        Haptics.doSuccessHapticFeedback()
        self.dismiss(animated: true, completion: nil)
    }
}

extension AddBudgetViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if budgetName.isEditing {
            budgetAmount.becomeFirstResponder()
        } else {
            if save.isEnabled {
                budgetAmount.resignFirstResponder()
                addNewBudgetOnSave()
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
