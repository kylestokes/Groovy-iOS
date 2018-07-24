//
//  UserMenuViewController.swift
//  groovy
//
//  Created by Kyle Stokes on 7/22/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit
import Spring
import Pulley
import Firebase
import FirebaseUI

class UserMenuViewController: UIViewController {
    
    // MARK: Properties
    
    var budget: Budget!
    var userEmail: String!
    
    // MARK: Outlets
    
    @IBOutlet weak var userName: SpringLabel!
    @IBOutlet weak var numberOfBudgets: SpringLabel!
    @IBOutlet weak var amountSpent: SpringLabel!
    @IBOutlet weak var totalAmount: SpringLabel!
    @IBOutlet weak var amountLeft: SpringLabel!
    
    // MARK: Actions
    
    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
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
    }
}
