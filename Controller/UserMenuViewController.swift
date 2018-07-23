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

class UserMenuViewController: UIViewController {
    
    // MARK: Properties
    
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

    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
