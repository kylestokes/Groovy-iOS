//
//  BudgetCell.swift
//  groovy
//
//  Created by Kyle Stokes on 7/9/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit

class BudgetCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var shareIcon: UIImageView!
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // https://stackoverflow.com/a/42456157
        cellView.backgroundColor = UIColor.white
        cellView.layer.cornerRadius = 10
        // https://stackoverflow.com/a/25475536
        let shadowPath = UIBezierPath(roundedRect: cellView.bounds.insetBy(dx: 0, dy: -1), cornerRadius: 10)
        cellView.layer.masksToBounds = false
        cellView.layer.shadowColor = UIColor.darkGray.cgColor
        cellView.layer.shadowOffset = CGSize(width: CGFloat(0.6), height: CGFloat(3.0))
        cellView.layer.shadowOpacity = 0.2
        cellView.layer.shadowPath = shadowPath.cgPath
    }
}
