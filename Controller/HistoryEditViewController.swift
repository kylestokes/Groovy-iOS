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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Edit"
    }
}
