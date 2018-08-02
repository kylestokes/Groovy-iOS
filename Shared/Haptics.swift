//
//  Haptics.swift
//  groovy
//
//  Created by Kyle Stokes on 7/26/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import Foundation
import UIKit


struct Haptics {
    static func doLightHapticFeedback() {
        let light = UIImpactFeedbackGenerator(style: UIImpactFeedbackStyle.light)
        light.impactOccurred()
    }
    
    static func doSuccessHapticFeedback() {
        let success = UINotificationFeedbackGenerator()
        success.notificationOccurred(.success)
    }
}
