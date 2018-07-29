//
//  BudgetCell.swift
//  groovy
//
//  Created by Kyle Stokes on 7/9/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit


class BudgetCell: UITableViewCell {
    
    // MARK: Properties
    
    let cardRoundedCornerRadius = CGFloat(10)
    let cardWidth = UIScreen.main.bounds.width - 30
    let cardShadowOffset = CGSize(width: CGFloat(0.6), height: CGFloat(4.5))
    let cardShadowOpacity = Float(0.2)
    
    // MARK: - Outlets
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var shareIcon: UIImageView!
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // https://stackoverflow.com/a/42456157
        cellView.backgroundColor = UIColor.white
        cellView.layer.cornerRadius = cardRoundedCornerRadius
        cellView.frame.size.width = cardWidth
        // https://stackoverflow.com/a/25475536
        cellView.layer.masksToBounds = false
        cellView.layer.shadowColor = UIColor.darkGray.cgColor
        cellView.layer.shadowOffset = cardShadowOffset
        cellView.layer.shadowOpacity = cardShadowOpacity
        let shadowPath = UIBezierPath(roundedRect: cellView.bounds.insetBy(dx: 0, dy: -2), cornerRadius: cardRoundedCornerRadius)
        cellView.layer.shadowPath = shadowPath.cgPath
    }
}
