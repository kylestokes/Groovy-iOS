//
//  BudgetsViewController.swift
//  groovy
//
//  Created by Kyle Stokes on 6/28/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import GoogleSignIn
import Spring
import Pastel

class BudgetsViewController: UIViewController {
    
    // MARK: Properties
    var databaseReference: DatabaseReference!
    var budgets: [Budget]! = []
    var user: User?
    var userEmail = ""
    fileprivate var _databaseHandle: DatabaseHandle!
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    
    // MARK: Outlets
    
    @IBOutlet weak var budgetsTable: UITableView!
    @IBOutlet weak var addBudgetButton: UIButton!
    
    // MARK: Actions
    
    @IBAction func addBudget(_ sender: Any) {
        performSegue(withIdentifier: "addBudgetSegue", sender: self)
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FUIAuth.defaultAuthUI()?.delegate = self
        configAuth()
        configAddBudgetButton()
        
        // Add 'Edit-Done' button
        navigationItem.rightBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        
        // Remove table lines
        self.budgetsTable.separatorStyle = .none
    }
    
    // MARK: Config
    
    func configAuth() {
        // Configure firebase authentication
        // Add Sign-In providers
        let providers: [FUIAuthProvider] = [FUIGoogleAuth(), FUIFacebookAuth()]
        FUIAuth.defaultAuthUI()?.providers = providers
        
        _authHandle = Auth.auth().addStateDidChangeListener { (auth: Auth, user: User?) in
            // refresh table data
            self.budgets.removeAll(keepingCapacity: false)
            self.budgetsTable.reloadData()
            
            // check if there is a current user
            if let activeUser = user {
                // check if the current app user is the current Firebase user
                if self.user != activeUser {
                    self.user = activeUser
                    self.userEmail = user!.email!
                    self.observeBudgetsAdded()
                    self.observeBudgetsChanged()
                    self.observeBudgetsDeleted()
                }
            } else {
                // Allow user to authenticate if not already signed in
                self.authenticateUser()
            }
        }
    }
    
    func configAddBudgetButton() {
        addBudgetButton.layer.cornerRadius = addBudgetButton.frame.width / 2
        addBudgetButton.imageEdgeInsets = UIEdgeInsetsMake(14, 14, 14, 14)
    }
    
    func authenticateUser() {
        let authViewController = FUIAuth.defaultAuthUI()?.authViewController()
        self.present(authViewController!, animated: true, completion: nil)
    }
    
    func observeBudgetsAdded() {
        databaseReference = Database.database().reference()
        _databaseHandle = databaseReference.child("budgets").observe(.childAdded, with: { (snapshot: DataSnapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let uid = snapshot.key
                let budget = Budget.from(firebase: dictionary, uid: uid)
                if budget.createdBy == self.userEmail || (budget.sharedWith?.contains(self.userEmail))! {
                    self.budgets.append(budget)
                    self.budgetsTable.insertRows(at: [IndexPath(row: self.budgets.count - 1, section: 0)], with: .automatic)
                }
            }
        })
    }
    
    func observeBudgetsChanged() {
        // https://stackoverflow.com/a/47593739
        Database.database().reference().child("budgets").observe(.childChanged, with: { (snapshot: DataSnapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let uid = snapshot.key
                let changedBudget = Budget.from(firebase: dictionary, uid: uid)
                
                // Budget is already in budget list
                for budget in self.budgets {
                    if budget.id == uid {
                        if let index = self.budgets.index(where: { (aBudget) -> Bool in
                            aBudget.id == uid
                        }) {
                            let indexPath = IndexPath(item: index, section: 0)
                            // User got removed from shared list so remove budget
                            if !(changedBudget.sharedWith?.contains(self.userEmail))! {
                                self.budgets.remove(at: index)
                                self.budgetsTable.deleteRows(at: [indexPath], with: .bottom)
                                
                                // Budget got edited so update it
                            } else {
                                self.budgets[index] = changedBudget
                                self.budgetsTable.reloadRows(at: [indexPath], with: .top)
                            }
                        }
                    }
                }
                
                // Budget is not already in list and budget got shared with user
                // https://stackoverflow.com/a/28211238
                let budgetsThatHaveChangedUID = self.budgets.filter { $0.id == uid }
                if budgetsThatHaveChangedUID.isEmpty && (changedBudget.sharedWith?.contains(self.userEmail))! {
                    self.budgets.append(changedBudget)
                    self.budgetsTable.insertRows(at: [IndexPath(row: self.budgets.count - 1, section: 0)], with: .automatic)
                }
            }
        })
    }
    
    func observeBudgetsDeleted() {
        Database.database().reference().child("budgets").observe(.childRemoved, with: { (snapshot: DataSnapshot) in
            if ((snapshot.value as? [String: AnyObject]) != nil) {
                let uid = snapshot.key
                for budget in self.budgets {
                    if budget.id == uid {
                        if let index = self.budgets.index(where: { (aBudget) -> Bool in
                            aBudget.id == uid
                        }) {
                            self.budgets.remove(at: index)
                            let indexPath = IndexPath(item: index, section: 0)
                            self.budgetsTable.deleteRows(at: [indexPath], with: .bottom)
                        }
                    }
                }
            }
        })
    }
    
    func delete(budget: Budget) {
        if budget.createdBy == userEmail {
            Database.database().reference().child("budgets").child(budget.id!).removeValue()
            if let index = self.budgets.index(where: { (deleteBudget) -> Bool in
                deleteBudget.id == budget.id
            }) {
                self.budgets.remove(at: index)
                self.budgetsTable.reloadData()
            }
        } else {
            let alert = UIAlertController(title: "Hmmm...", message: "\(budget.name!) was created by \(budget.createdBy!). Only they can delete it.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Edit-Done actions
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            self.budgetsTable.setEditing(true, animated: true)
        } else {
            self.budgetsTable.setEditing(false, animated: true)
        }
    }
    
    func signOut() {
        do {
            try FUIAuth.defaultAuthUI()?.signOut()
        } catch {
            print("Unable to sign out: \(error)")
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let addBudgetViewController = segue.destination as! AddBudgetViewController
        addBudgetViewController.userEmail = userEmail
        addBudgetViewController.databaseReference = databaseReference
    }
}

// MARK: - BudgetViewController: UITableViewDelegate, UITableViewDataSource

extension BudgetsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return budgets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = budgetsTable.dequeueReusableCell(withIdentifier: "budgetCell", for: indexPath) as! BudgetCell
        cell.title.text = budgets[indexPath.row].name
        let spent = formatAsCurrency(budgets[indexPath.row].spent!)
        let setAmount = formatAsCurrency(budgets[indexPath.row].setAmount!)
        cell.subtitle.text = "\(spent) of \(setAmount)"
        // https://stackoverflow.com/a/44752964
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let budgetToDelete = budgets[indexPath.row]
            let alert = UIAlertController(title: "Delete \(budgetToDelete.name!)", message: "Are you sure you want to delete this?", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (delete) in
                self.delete(budget: budgetToDelete)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (cancel) in
                self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            self.budgetsTable.dataSource?.tableView!(self.budgetsTable, commit: .delete, forRowAt: indexPath)
            return
        }
        deleteButton.backgroundColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        return [deleteButton]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let budgetDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "budgetDetail") as! BudgetDetailViewController
        budgetDetailViewController.budget = self.budgets[indexPath.row]
        budgetDetailViewController.userEmail = userEmail
        budgetDetailViewController.databaseReference = databaseReference
        navigationController?.pushViewController(budgetDetailViewController, animated: true)
        
    }
}

extension BudgetsViewController: FUIAuthDelegate {
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return AuthPickerViewController(nibName: "AuthPickerViewController", bundle: Bundle.main, authUI: authUI)
    }
    
    func emailEntryViewController(forAuthUI authUI: FUIAuth) -> FUIEmailEntryViewController {
        return EmailViewController(nibName: "EmailViewController", bundle: Bundle.main, authUI: authUI)
    }
    
    func passwordSignInViewController(forAuthUI authUI: FUIAuth, email: String) -> FUIPasswordSignInViewController {
        return PasswordSignInViewController(nibName: "PasswordSignInViewController", bundle: Bundle.main, authUI: authUI, email: email)
    }
    
    func passwordSignUpViewController(forAuthUI authUI: FUIAuth, email: String) -> FUIPasswordSignUpViewController {
        return PasswordSignUpViewController(nibName: "PasswordSignUpViewController", bundle: Bundle.main, authUI: authUI, email: email)
    }
    
    func passwordRecoveryViewController(forAuthUI authUI: FUIAuth, email: String) -> FUIPasswordRecoveryViewController {
        return PasswordRecoveryViewController(nibName: "PasswordRecoveryViewController", bundle: Bundle.main, authUI: authUI, email: email)
    }
}

