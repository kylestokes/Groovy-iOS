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
import DeviceKit

class UserMenuViewController: UIViewController {
    
    // MARK: Properties
    
    var budgets: [Budget]!
    var userEmail: String!
    var device: Device!
    let iPadsThatNeedAdjusting = [Device.iPad5, Device.iPad6, Device.iPadAir, Device.iPadAir2, Device.iPadPro9Inch, Device.iPadPro10Inch, Device.simulator(Device.iPadPro10Inch), Device.simulator(Device.iPadPro9Inch), Device.simulator(Device.iPadAir), Device.simulator(Device.iPadAir2), Device.simulator(Device.iPad5), Device.simulator(Device.iPad6)]
    
    // MARK: Outlets
    
    @IBOutlet weak var userName: SpringLabel!
    @IBOutlet weak var numberOfBudgets: SpringLabel!
    @IBOutlet weak var budgetLabel: SpringLabel!
    @IBOutlet weak var amountSpent: SpringLabel!
    @IBOutlet weak var totalAmount: SpringLabel!
    @IBOutlet weak var amountLeft: SpringLabel!
    @IBOutlet weak var leftToSpend: SpringLabel!
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
        configDevice()
        configNavBar()
        configDisplayName()
        configNumberOfBudgets()
        configBudgetsLabel()
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
    
    func configDevice() {
        device = Device()
    }
    
    func configNavBar() {
        self.navigationController?.navigationBar.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
    }
    
    func configDisplayName() {
        let displayName = String(userEmail.split(separator: "@")[0])
        userName.text = displayName
        userName.font =  device.isOneOf(iPadsThatNeedAdjusting) ? UIFont.systemFont(ofSize: 14.0) : UIFont.boldSystemFont(ofSize: 17.0)
    }
    
    func configNumberOfBudgets() {
        var numberOfBudgetsForUser = 0
        for _ in budgets {
            numberOfBudgetsForUser += 1
        }
        numberOfBudgets.text = String(numberOfBudgetsForUser)
        numberOfBudgets.font =  device.isOneOf(iPadsThatNeedAdjusting) ? UIFont.boldSystemFont(ofSize: 20.0) : UIFont.boldSystemFont(ofSize: 45.0)
    }
    
    func configBudgetsLabel() {
        budgetLabel.text = budgets.count == 1 ? "budget" : "budgets"
    }
    
    func configAmountSpent() {
        var amountSpentForUser: Double = 0.0
        for budget in budgets {
            amountSpentForUser += budget.spent!
        }
        amountSpent.text = formatAsCurrency(amountSpentForUser)
        amountSpent.font =  device.isOneOf(iPadsThatNeedAdjusting) ? UIFont.boldSystemFont(ofSize: 20.0) : UIFont.boldSystemFont(ofSize: 35.0)
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
        amountLeft.font =  device.isOneOf(iPadsThatNeedAdjusting) ? UIFont.boldSystemFont(ofSize: 20.0) : UIFont.boldSystemFont(ofSize: 35.0)
    }
    
    func configQuoteButton() {
        quoteButton.layer.cornerRadius = quoteButton.frame.width / 2
    }
}
