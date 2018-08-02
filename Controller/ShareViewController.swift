//
//  ShareViewController.swift
//  groovy
//
//  Created by Kyle Stokes on 7/15/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit
import Firebase
import Spring
import DeviceKit

class ShareViewController: UIViewController {
    
    // MARK: Properties
    
    var databaseReference: DatabaseReference!
    var budget: Budget!
    var userEmail: String!
    let iPadsThatNeedAdjusting = [Device.iPad5, Device.iPad6, Device.iPadAir, Device.iPadAir2, Device.iPadPro9Inch, Device.iPadPro10Inch, Device.simulator(Device.iPadPro10Inch), Device.simulator(Device.iPadPro9Inch), Device.simulator(Device.iPadAir), Device.simulator(Device.iPadAir2), Device.simulator(Device.iPad5), Device.simulator(Device.iPad6)]
    
    // MARK: - Outlets
    
    @IBOutlet weak var shareIcon: SpringImageView!
    @IBOutlet weak var sharedWith: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var shareLabel: UILabel!
    
    // MARK: - Actions
    
    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        databaseReference.child("budgets").child("\(budget.id!)").setValue(getUpdatedBudget() as NSDictionary) { (error, ref) in
            if error == nil {
                self.email.resignFirstResponder()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func shareBudgetOnSave(_ sender: UIBarButtonItem) {
        shareBudget()
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configEmailTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        configNavBar()
        configShareIcon()
        animateShareIcon()
        configShareLabel()
        configTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    func configNavBar() {
        // Owner can Save to add new email
        if userEmail == budget.createdBy {
            navigationItem.rightBarButtonItem?.isEnabled = false
            // Hide 'Save' for non-owner
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func configEmailTextField() {
        // Owner
        if userEmail == budget.createdBy {
            email.delegate = self
            email.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
            // Hide for non-owner
        } else {
            email.isEnabled = false
        }
    }
    
    func configShareLabel() {
        shareLabel.text = userEmail == budget.createdBy ? "Add email address to share" : "Only owner can share"
    }
    
    func configTableView() {
        // Open keyboard for email if no shared emails exist
        if budget.sharedWith?.count == 1 {
            email.becomeFirstResponder()
        }
        
        // Separator color lines
        tableView.separatorColor = UIColor.lightGray
        
        // Remove 'excess' lines
        tableView.tableFooterView = UIView()
    }
    
    func configShareIcon() {
        shareIcon.image = budget.isShared! ? #imageLiteral(resourceName: "share-filled") : #imageLiteral(resourceName: "share-display")
        shareIcon.image = shareIcon.image!.withRenderingMode(.alwaysTemplate)
        shareIcon.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
    }
    
    func animateShareIcon() {
        shareIcon.animation = "zoomIn"
        shareIcon.duration = 1.5
        shareIcon.animate()
    }
    
    func removeEmailFromSharing(_ email: String) {
        let indexOfEmailToRemove = budget.sharedWith?.index(of: email)
        budget.sharedWith?.remove(at: indexOfEmailToRemove!)
        
        if budget.sharedWith?.count == 1 {
            // Budget is not shared
            budget.isShared = false
            
            // Remove user from shared list
            budget.sharedWith![0] = "none"
            
            // Enable icon
            shareIcon.image = #imageLiteral(resourceName: "share-display")
            shareIcon.image = shareIcon.image!.withRenderingMode(.alwaysTemplate)
            shareIcon.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
            
            // Hide UI
            tableView.isHidden = true
            shareLabel.isHidden = false
            sharedWith.isHidden = true
        }
        
        firebaseSave()
        tableView.reloadData()
    }
    
    @objc func shareBudget() {
        
        // If first time sharing email, add user to shared list
        if budget.isShared == false {
            budget.sharedWith![0] = userEmail.lowercased()
        }
        
        // Add new email
        var sharedWithEmails = budget.sharedWith!
        sharedWithEmails.append(email.text!.lowercased())
        budget.sharedWith = sharedWithEmails
        
        // Budget is now shared
        budget.isShared = true
        
        // Enable new icon
        shareIcon.image = #imageLiteral(resourceName: "share-filled")
        shareIcon.image = shareIcon.image!.withRenderingMode(.alwaysTemplate)
        shareIcon.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        
        // Save in Firebase
        firebaseSave()
        
        // Add email to table with animation if not first budget
        if budget.sharedWith!.count > 2 {
            let indexOfEmailToAdd = budget.sharedWith?.index(of: email.text!)
            let indexPath = IndexPath(item: indexOfEmailToAdd!, section: 0)
            tableView.insertRows(at: [indexPath], with: .top)
        } else {
            // Add user email to first row
            tableView.reloadData()
        }

        
        // Show UI
        tableView.isHidden = false
        shareLabel.isHidden = false
        sharedWith.isHidden = false
        
        // Reconfig email text field
        email.text = ""
        email.resignFirstResponder()
        
        // Reconfig 'Save' button
        saveButton.isEnabled = false
    }
    
    func firebaseSave() {
        databaseReference.child("budgets").child("\(budget.id!)").setValue(getUpdatedBudget() as NSDictionary)
    }
    
    func getUpdatedBudget() -> [String : Any] {
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
        return budgetDictionary
    }
    
    @objc func textFieldDidChange() {
        saveButton.isEnabled = (email.text?.count)! > 0 ? true : false
    }
    
    // Close keyboard when tapping outside of keyboard
    // https://medium.com/@KaushElsewhere/how-to-dismiss-keyboard-in-a-view-controller-of-ios-3b1bfe973ad1
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let device = Device()
        // Only move view if editing bottom textfield
        if self.email.isEditing && device.isOneOf(iPadsThatNeedAdjusting) {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let device = Device()
        if device.isOneOf(iPadsThatNeedAdjusting) {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height / 2
    }
    
}

extension ShareViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return budget.sharedWith?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "emailCell", for: indexPath)
        cell.textLabel?.textColor = UIColor.darkGray
        // Show gray for Owner email
        if budget.sharedWith![indexPath.row] == budget.createdBy {
            cell.textLabel?.text = (budget.sharedWith?[indexPath.row])! + " (Owner)"
            cell.textLabel?.textColor = UIColor.lightGray
        } else if budget.sharedWith![indexPath.row] != "none" {
            // If owner, then show all emails as default
            if budget.createdBy == userEmail {
                cell.textLabel?.text = budget.sharedWith?[indexPath.row]
            // Non-owner can only see themselves as default
            } else {
                cell.textLabel?.text = budget.sharedWith?[indexPath.row]
                if budget.sharedWith?[indexPath.row] != userEmail {
                    cell.textLabel?.textColor = UIColor.lightGray
                }
            }
        // Hide table if no shared emails
        } else {
            tableView.isHidden = true
            sharedWith.isHidden = true
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let emailToDelete = budget.sharedWith![indexPath.row]
            let deleteAction = UIAlertAction(title: "Remove", style: .default, handler: { (email) in
                self.removeEmailFromSharing(emailToDelete)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let actions = [deleteAction, cancelAction]
            showActionSheetAlert(title: "Remove \(emailToDelete)?", message: "Removing \(emailToDelete) will no longer allow them to see this budget", actions: actions)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .default, title: "Remove") { (action, indexPath) in
            self.tableView.dataSource?.tableView!(self.tableView, commit: .delete, forRowAt: indexPath)
            return
        }
        deleteButton.backgroundColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        return [deleteButton]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // If owner, all budgets are editable other than owner email
        if budget.createdBy == userEmail {
            let isOwnerEmail = budget.sharedWith![indexPath.row] == budget.createdBy
            let returnValue = isOwnerEmail ? false : true
            return returnValue
            // Not owner so only user email is editable
        } else {
            let isUserEmail = budget.sharedWith![indexPath.row] == userEmail
            return isUserEmail
        }
    }
}

extension ShareViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !(email.text?.isEmpty)! {
            shareBudget()
        }
        email.resignFirstResponder()
        return true
    }
}
