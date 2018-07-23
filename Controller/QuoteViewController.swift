//
//  QuoteViewController.swift
//  groovy
//
//  Created by Kyle Stokes on 7/22/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit
import Pulley

class QuoteViewController: UIViewController {
    
    // MARK: Actions
    
    @IBAction func shareQuote(_ sender: UIButton) {
        let shareController = UIActivityViewController(activityItems: ["The journey of a thousand miles begins with one step."], applicationActivities: nil)
        present(shareController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension QuoteViewController: PulleyDrawerViewControllerDelegate {
    func supportedDrawerPositions() -> [PulleyPosition] {
        return [PulleyPosition.partiallyRevealed, PulleyPosition.closed, PulleyPosition.collapsed]
    }
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 80.0
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 300.0
    }
}
