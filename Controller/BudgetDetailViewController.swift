//
//  BudgetDetailViewController.swift
//  groovy
//
//  Created by Kyle Stokes on 7/12/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit
import Firebase
import UICircularProgressRing
import Spring
import DeviceKit

class BudgetDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    var databaseReference: DatabaseReference!
    var budget: Budget!
    var userEmail: String!
    var progressRing: UICircularProgressRing!
    
    // MARK: - Outlets
    
    @IBOutlet weak var spentLabel: UILabel!
    @IBOutlet weak var spentOfLabel: UILabel!
    @IBOutlet weak var leftToSpendAmountLabel: UILabel!
    @IBOutlet weak var leftToSpendLabel: UILabel!
    @IBOutlet weak var addPurchaseButton: UIButton!
    
    // MARK: -  Actions
    
    @IBAction func addPurchase(_ sender: UIButton) {
        let spentMoneyViewController = storyboard?.instantiateViewController(withIdentifier: "spentMoney") as! SpentMoneyViewController
        spentMoneyViewController.budget = budget
        spentMoneyViewController.userEmail = userEmail
        spentMoneyViewController.databaseReference = databaseReference
        present(spentMoneyViewController, animated: true, completion: nil)
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigationBar()
        configProgressRing()
        configAddPurchaseButton()
        addLeftToSpendLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getBudgetFromFirebase()
    }
    
    // MARK: - Config
    
    func configNavigationBar() {
        navigationItem.title = budget.name
        navigationController?.navigationBar.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        
        // Share
        let share = budget.isShared! ? UIBarButtonItem(image: #imageLiteral(resourceName: "shared-filled-icon"), style: .done, target: self, action: #selector(shareBudget)) : UIBarButtonItem(image: #imageLiteral(resourceName: "share"), style: .done, target: self, action: #selector(shareBudget))
        
        // More
        let more = UIBarButtonItem(image: #imageLiteral(resourceName: "dots"), style: .done, target: self, action: #selector(showMoreSheet))
        
        // Right bar button items
        navigationItem.rightBarButtonItems = [more, share]
    }
    
    func configProgressRing() {
        let device = Device()
        let iPhone5Devices = [Device.iPhone5, Device.iPhone5s, Device.iPhone5c, Device.iPhoneSE, Device.simulator(Device.iPhone5), Device.simulator(Device.iPhone5s), Device.simulator(Device.iPhone5c),Device.simulator(Device.iPhoneSE)]
        
        let iPhone678Devices = [Device.iPhone6, Device.simulator(Device.iPhone6), Device.iPhone7, Device.simulator(Device.iPhone7), Device.iPhone8, Device.simulator(Device.iPhone8)]
        
        if device.isOneOf(iPhone5Devices) {
            progressRing = UICircularProgressRing(frame: CGRect(x: view.bounds.midX - 80, y: 130, width: 160, height: 160))
        } else if device.isOneOf(iPhone678Devices) {
           progressRing = UICircularProgressRing(frame: CGRect(x: view.bounds.midX - 105, y: 155, width: 210, height: 210))
        } else if device.isOneOf(iPadsThatNeedAdjusting.noniPadPro12InchDevices) {
            progressRing = UICircularProgressRing(frame: CGRect(x: view.bounds.midX - 50, y: 120, width: 105, height: 105))
        } else if device.isOneOf(iPadsThatNeedAdjusting.iPadPro12InchDevices) {
            progressRing = UICircularProgressRing(frame: CGRect(x: view.bounds.midX - 105, y: 140, width: 210, height: 210))
        }
        else {
            progressRing = UICircularProgressRing(frame: CGRect(x: view.bounds.midX - 105, y: 190, width: 210, height: 210))
        }
        progressRing.innerCapStyle = .round
        progressRing.outerCapStyle = .round
        progressRing.ringStyle = .gradient
        progressRing.gradientColors = [
            UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1),    // pink
            UIColor(red:0.99, green:0.89, blue:0.54, alpha:1.0)             // yellow
        ]
        progressRing.outerRingColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        
        if device.isOneOf(iPadsThatNeedAdjusting.noniPadPro12InchDevices) {
            progressRing.innerRingWidth = 10
            progressRing.outerRingWidth = 10
            progressRing.font = UIFont.boldSystemFont(ofSize: 14)
        } else {
            progressRing.innerRingWidth = device.isOneOf(iPhone5Devices) ? 15 : 20
            progressRing.outerRingWidth = device.isOneOf(iPhone5Devices) ? 15 : 20
            progressRing.font = device.isOneOf(iPhone5Devices) ? UIFont.boldSystemFont(ofSize: 20) : UIFont.boldSystemFont(ofSize: 25)
            progressRing.valueIndicator = "% spent"
        }
        view.addSubview(progressRing)
    }
    
    func configAddPurchaseButton() {
        addPurchaseButton.layer.cornerRadius = addPurchaseButton.frame.width / 2
        addPurchaseButton.imageEdgeInsets = UIEdgeInsetsMake(14, 14, 14, 14)
    }
    
    func animateToPercentageSpent() {
        // Prevent divide by zero errors if user enters any value less than zero
        var setAmount = 0.0
        var spent = 0.0
        setAmount = budget.setAmount! < 1.0 ? budget.setAmount! : (budget.setAmount?.rounded())!
        spent = budget.spent! < 1.0 ? budget.spent! : (budget.spent?.rounded())!
        var percentage = CGFloat(spent) / CGFloat(setAmount)
        
        if percentage.isNaN {
            percentage = 0
        }
        
        // Percentage is greater than 500%
        if percentage > 5 {
            percentage = 5
            progressRing.valueIndicator = "+ %"
        } else {
            progressRing.valueIndicator = "% spent"
        }
        
        progressRing.startProgress(to: CGFloat(percentage) * 100, duration: 2.0)
    }
    
    func addToSpendText() {
        let device = Device()
        spentLabel.text = formatAsCurrency(budget.spent!)
        if device.isOneOf(iPadsThatNeedAdjusting.noniPadPro12InchDevices) {
            spentLabel.font = UIFont.boldSystemFont(ofSize: 20)
        }
    }
    
    func addSpentText() {
        spentOfLabel.text = "spent of \(formatAsCurrency(budget.setAmount!))"
    }
    
    func addLeftToSpentAmountLabel() {
        let device = Device()
        leftToSpendAmountLabel.text = formatAsCurrency(budget.left!)
        if device.isOneOf(iPadsThatNeedAdjusting.noniPadPro12InchDevices) {
            leftToSpendAmountLabel.font = UIFont.boldSystemFont(ofSize: 20)
        }
    }
    
    func addLeftToSpendLabel() {
        leftToSpendLabel.text = "left to spend"
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
    
    @objc func shareBudget() {
        let shareViewController = storyboard?.instantiateViewController(withIdentifier: "shareBudget") as! ShareViewController
        shareViewController.budget = budget
        shareViewController.userEmail = userEmail
        shareViewController.databaseReference = databaseReference
        self.present(shareViewController, animated: true, completion: nil)
    }
    
    func delete(budget: Budget) {
        if budget.createdBy == userEmail {
            let delete = UIAlertAction(title: "Delete", style: .default, handler: { (delete) in
                Database.database().reference().child("budgets").child(budget.id!).removeValue()
                self.navigationController?.popViewController(animated: true)
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let actions = [delete, cancel]
            showActionSheetAlert(title: "Delete \(budget.name!)", message: "Are you sure you want to delete this budget?", actions: actions)
        } else {
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            showActionSheetAlert(title: "Hmmm...", message: "'\(budget.name!)' was created by \(budget.createdBy!). Only they can delete it.", actions: [okAction])
        }
    }
    
    // https://stackoverflow.com/a/39267898
    @objc func showMoreSheet() {
        
        let history = UIAlertAction(title: "History", style: .default , handler:{ (UIAlertAction) in
            self.performSegue(withIdentifier: "showHistorySegue", sender: self)
        })
        
        let edit = UIAlertAction(title: "Edit", style: .default , handler:{ (UIAlertAction) in
            let editBudgetViewController = self.storyboard?.instantiateViewController(withIdentifier: "editBudget") as! EditBudgetViewController
            editBudgetViewController.databaseReference = self.databaseReference
            editBudgetViewController.budget = self.budget
            editBudgetViewController.userEmail = self.userEmail
            self.present(editBudgetViewController, animated: true, completion: nil)
        })
        
        let delete = UIAlertAction(title: "Delete", style: .default , handler:{ (UIAlertAction) in
            self.delete(budget: self.budget)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let actions = [history, edit, delete, cancel]
        showActionSheetAlert(title: nil, message: nil, actions: actions)
    }
    
    func getBudgetFromFirebase() {
        databaseReference.child("budgets").child("\(budget.id!)").observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let uid = snapshot.key
                let budget = Budget.from(firebase: dictionary, uid: uid)
                self.budget = budget
                self.title = budget.name!
                self.addToSpendText()
                self.addSpentText()
                self.addLeftToSpentAmountLabel()
                self.configNavigationBar()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.animateToPercentageSpent()
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let historyNavigationController = segue.destination as! UINavigationController
        let historyViewController = historyNavigationController.topViewController as! HistoryViewController
        historyViewController.budget = self.budget
        historyViewController.userEmail = self.userEmail
        historyViewController.databaseReference = self.databaseReference
    }
}
