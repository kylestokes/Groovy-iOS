//
//  UserMenuViewController.swift
//  groovy
//
//  Created by Kyle Stokes on 7/22/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit
import Spring
import Firebase
import FirebaseUI

class UserMenuViewController: UIViewController {
    
    // MARK: Properties
    
    var budgets: [Budget]!
    var userEmail: String!
    
    // MARK: Outlets
    
    @IBOutlet weak var userName: SpringLabel!
    @IBOutlet weak var numberOfBudgets: SpringLabel!
    @IBOutlet weak var amountSpent: SpringLabel!
    @IBOutlet weak var totalAmount: SpringLabel!
    @IBOutlet weak var amountLeft: SpringLabel!
    @IBOutlet weak var quoteButton: SpringButton!
    
    // MARK: Actions
    
    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func quote(_ sender: Any) {
        let quoteViewController = storyboard?.instantiateViewController(withIdentifier: "quoteView") as! QuoteViewController
        navigationController?.pushViewController(quoteViewController, animated: true)
    }
    
    @IBAction func signOut(_ sender: UIBarButtonItem) {
        do {
            try FUIAuth.defaultAuthUI()?.signOut()
            self.dismiss(animated: true, completion: nil)
        } catch {
            let alert = UIAlertController(title: "Sign Out Error", message: "Unable to sign out — try again in a second", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configNavBar()
        configDisplayName()
        configNumberOfBudgets()
        configAmountSpent()
        configTotalAmount()
        configAmountLeft()
        configQuoteButton()
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
    
    func configNavBar() {
        self.navigationController?.navigationBar.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
    }
    
    func configDisplayName() {
        let displayName = String(userEmail.split(separator: "@")[0])
        userName.text = displayName
    }
    
    func configNumberOfBudgets() {
        var numberOfBudgetsForUser = 0
        for _ in budgets {
            numberOfBudgetsForUser += 1
        }
        numberOfBudgets.text = String(numberOfBudgetsForUser)
    }
    
    func configAmountSpent() {
        var amountSpentForUser: Double = 0.0
        for budget in budgets {
            amountSpentForUser += budget.spent!
        }
        amountSpent.text = formatAsCurrency(amountSpentForUser)
    }
    
    func configTotalAmount() {
        var totalAmountForUser: Double = 0.0
        for budget in budgets {
            totalAmountForUser += budget.setAmount!
        }
        totalAmount.text = "spent of \(formatAsCurrency(totalAmountForUser))"
    }
    
    func configAmountLeft() {
        var amountLeftForUser: Double = 0.0
        for budget in budgets {
            amountLeftForUser += budget.left!
        }
        amountLeft.text = formatAsCurrency(amountLeftForUser)
    }
    
    func configQuoteButton() {
        quoteButton.layer.cornerRadius = quoteButton.frame.width / 2
    }
}
