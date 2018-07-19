//
//  HistoryEditViewController.swift
//  groovy
//
//  Created by Kyle Stokes on 7/17/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit

class HistoryEditViewController: UIViewController {
    
    // MARK: - Properties
    
    var budget: Budget!
    var purchase: String!
    var saveButton: UIBarButtonItem!
    
    // MARK: - Outlets
    
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var note: UITextField!
    
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
        amount.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        amount.becomeFirstResponder()
    }
    
    func configNoteField() {
        let noteText = String(purchase.split(separator: ":")[1])
        note.text = noteText
        note.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        note.delegate = self
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
        print("Save")
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
}
