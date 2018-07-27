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
    @IBOutlet weak var noBudgetsLabel: UILabel!
    @IBOutlet weak var createOneLabel: UILabel!
    
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
                    self.userEmail = user!.email!.lowercased()
                    self.observeBudgetsAdded()
                    self.observeBudgetsChanged()
                    self.observeBudgetsDeleted()
                    self.configMenuButton()
                    self.displayInterface()
                }
            } else {
                // Hide UI if no authorized user
                self.hideUserInterface()
                // Allow user to authenticate if not already signed in
                self.authenticateUser()
            }
        }
    }
    
    func configAddBudgetButton() {
        addBudgetButton.layer.cornerRadius = addBudgetButton.frame.width / 2
        addBudgetButton.imageEdgeInsets = UIEdgeInsetsMake(14, 14, 14, 14)
    }
    
    func configMenuButton() {
        // https://stackoverflow.com/a/48658154
        let menuButton = UIButton(type: .custom)
        menuButton.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        let menuImage = UIImage(named: "menu")
        let menuImageColored = menuImage?.withRenderingMode(.alwaysTemplate)
        menuButton.setImage(menuImageColored, for: .normal)
        menuButton.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        menuButton.addTarget(self, action: #selector(showMenu), for: UIControlEvents.touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: menuButton)
        let currentWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24)
        currentWidth?.isActive = true
        let currentHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24)
        currentHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
    }
    
    func displayInterface() {
        self.addBudgetButton.isHidden = false
        self.title = "Budgets"
        if budgets.count == 0 {
            noBudgetLabelsHidden(false)
            budgetsTable.isHidden = true
        } else {
            noBudgetLabelsHidden(true)
            budgetsTable.isHidden = false
        }
    }
    
    func hideUserInterface() {
        self.title = "Budgets"
        self.budgetsTable.isHidden = true
    }
    
    func noBudgetLabelsHidden(_ isHidden: Bool) {
        self.noBudgetsLabel.isHidden = isHidden
        self.createOneLabel.isHidden = isHidden
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
                    self.displayInterface()
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
                            if !(changedBudget.sharedWith?.contains(self.userEmail))! && changedBudget.createdBy != self.userEmail {
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
                if budgets.count == 0 {
                    noBudgetLabelsHidden(false)
                }
            }
        } else {
            let alert = UIAlertController(title: "Hmmm...", message: "\(budget.name!) was created by \(budget.createdBy!). Only they can delete it.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
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
        if segue.identifier == "addBudgetSegue" {
            let addBudgetViewController = segue.destination as! AddBudgetViewController
            addBudgetViewController.userEmail = userEmail
            addBudgetViewController.databaseReference = databaseReference
        } else {
            // userMenuSegue
            let userMenuNavigationController = segue.destination as! UINavigationController
            let userMenuViewController = userMenuNavigationController.topViewController as! UserMenuViewController
            userMenuViewController.budgets = self.budgets
            userMenuViewController.userEmail = self.userEmail
        }
    }
    
    @objc func showMenu() {
        performSegue(withIdentifier: "userMenuSegue", sender: self)
    }
}

// MARK: - BudgetViewController: UITableViewDelegate, UITableViewDataSource

extension BudgetsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if budgets.count == 0 {
            tableView.isHidden = true
            return 0
        } else {
            tableView.isHidden = false
            return budgets.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = budgetsTable.dequeueReusableCell(withIdentifier: "budgetCell", for: indexPath) as! BudgetCell
        cell.title.text = budgets[indexPath.row].name
        let spent = formatAsCurrency(budgets[indexPath.row].spent!)
        let setAmount = formatAsCurrency(budgets[indexPath.row].setAmount!)
        cell.subtitle.text = "\(spent) of \(setAmount)"
        cell.shareIcon.image = budgets[indexPath.row].isShared! ? #imageLiteral(resourceName: "user") : nil
        if cell.shareIcon.image != nil {
            cell.shareIcon.image = cell.shareIcon.image!.withRenderingMode(.alwaysTemplate)
            cell.shareIcon.tintColor = UIColor(red:0.91, green:0.91, blue:0.91, alpha:1.0)
        }
        // https://stackoverflow.com/a/44752964
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let budgetToDelete = budgets[indexPath.row]
            let alert = UIAlertController(title: "Delete \(budgetToDelete.name!)", message: "Are you sure you want to delete this budget?", preferredStyle: .actionSheet)
            
            alert.view.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
            
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
        
        let editButton = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in
            let editBudgetViewController = self.storyboard?.instantiateViewController(withIdentifier: "editBudget") as! EditBudgetViewController
            editBudgetViewController.budget = self.budgets[indexPath.row]
            editBudgetViewController.userEmail = self.userEmail
            editBudgetViewController.databaseReference = self.databaseReference
            self.present(editBudgetViewController, animated: true, completion: nil)
        }
        
        let shareButton = UITableViewRowAction(style: .default, title: "Share") { (action, indexPath) in
            let shareBudgetViewController = self.storyboard?.instantiateViewController(withIdentifier: "shareBudget") as! ShareViewController
            shareBudgetViewController.budget = self.budgets[indexPath.row]
            shareBudgetViewController.userEmail = self.userEmail
            shareBudgetViewController.databaseReference = self.databaseReference
            self.present(shareBudgetViewController, animated: true, completion: nil)
        }
        
        deleteButton.backgroundColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        editButton.backgroundColor = UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.0)
        shareButton.backgroundColor = UIColor(red:0.24, green:0.44, blue:0.65, alpha:1.0)
        
        return [deleteButton, shareButton, editButton]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Haptics.doLightHapticFeedback()
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

extension UIResponder {
    var parentViewController: UIViewController? {
        return (self.next as? UIViewController) ?? self.next?.parentViewController
    }
}

