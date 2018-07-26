//
//  ActivityIndicator.swift
//  Groovy
//
//  Created by Kyle Stokes on 7/25/18
//
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import Foundation
import UIKit

// http://brainwashinc.com/2017/07/21/loading-activity-indicator-ios-swift/
class ActivityIndicator {
    static func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        activityIndicator.startAnimating()
        activityIndicator.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(activityIndicator)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    static func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}
