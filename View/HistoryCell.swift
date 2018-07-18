//
//  HistoryCell.swift
//  groovy
//
//  Created by Kyle Stokes on 7/17/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var note: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
