//
//  BudgetDetailViewController.swift
//  groovy
//
//  Created by Kyle Stokes on 7/12/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit

class BudgetDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    var budget: Budget!
    
    // MARK: - Outlets
    
    @IBOutlet weak var budgetName: UILabel!
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        budgetName.text = budget.name
    }

}
