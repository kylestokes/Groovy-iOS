//
//  AuthPickerViewController.swift
//  groovy
//
//  Created by Kyle Stokes on 6/29/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit
import FirebaseUI
import Pastel
import Spring
import DeviceKit

class AuthPickerViewController: FUIAuthPickerViewController {
    
    var imageView: SpringImageView!
    var peaceLabel: SpringLabel!
    var bodyText: SpringLabel!
    var device: Device!
    let iphonesThatNeedAdjusting = [Device.iPhone4, Device.iPhone4s, Device.iPhone5, Device.iPhone5s, Device.iPhone5c, Device.iPhoneSE, Device.simulator(Device.iPhone5s), Device.simulator(Device.iPhoneSE)]
    let iPadsThatNeedAdjusting = [Device.iPad5, Device.iPad6, Device.iPadAir, Device.iPadAir2, Device.iPadPro9Inch, Device.iPadPro10Inch, Device.simulator(Device.iPadPro10Inch), Device.simulator(Device.iPadPro9Inch), Device.simulator(Device.iPadAir), Device.simulator(Device.iPadAir2), Device.simulator(Device.iPad5), Device.simulator(Device.iPad6)]
    
    // MARK: Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Status bar to white
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Get device app is running on
        getDevice()
        
        // Navbar
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.leftBarButtonItem = nil
        self.navigationController?.navigationBar.preservesSuperviewLayoutMargins = true
        self.title = ""
        navigationItem.backBarButtonItem?.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        navigationItem.backBarButtonItem?.title = ""
        
        // Add icon
        addLavaLampIcon()
        
        // Add 'Peace.' text
        addPeaceText()
        
        // Add body text
        addBodyText()
        
        // Add animated gradient background
        self.view.insertSubview(getAnimatedGradientBackground(), at: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        
        // Remove animations when leaving view
        self.imageView.animation = "fadeOut"
        self.imageView.animate()
        
        if peaceLabel != nil {
            self.peaceLabel.animation = "fadeOut"
            self.peaceLabel.animate()
        }
        
        if bodyText != nil {
            self.bodyText.animation = "fadeOut"
            self.bodyText.animate()
        }
    }
    
    func getDevice() {
        // If device is in 'devicesThatNeedAdjusting', the peace and body text on this view will be removed
        device = Device()
    }
    
    
    func addLavaLampIcon() {
        var height: Int
        var y: Int
        let peaceHandOriginal = UIImage(named: "lava")
        // apply color to peace image
        // https://stackoverflow.com/a/27163581
        let peaceHandGradient = peaceHandOriginal?.withRenderingMode(.alwaysTemplate)
        imageView = SpringImageView(image: peaceHandGradient)
        imageView.tintColor = UIColor.white
        imageView.contentMode = .scaleAspectFit
        if device.isOneOf(iPadsThatNeedAdjusting) {
            height = 75
            y = 25
        } else {
            height = device.isOneOf(iphonesThatNeedAdjusting) ? 120 : 200
            y = 50
        }
        imageView.frame = CGRect(x: 20, y: (navigationController?.navigationBar.frame.origin.y)! + CGFloat(y), width: view.frame.size.width - 40, height: CGFloat(height))
        imageView.animation = "fadeInUp"
        imageView.duration = 2
        imageView.animate()
        self.view.addSubview(imageView)
    }
    
    func addPeaceText() {
        var y: Int
        var fontSize: Int
        
        if device.isOneOf(iPadsThatNeedAdjusting) {
            y = 110
            fontSize = 34
        } else {
            y = device.isOneOf(iphonesThatNeedAdjusting) ? 190 : 270
            fontSize = device.isOneOf(iphonesThatNeedAdjusting) ? 35 : 50
        }
        peaceLabel = SpringLabel(frame: CGRect(x: 0, y: (navigationController?.navigationBar.frame.origin.y)! + CGFloat(y), width: view.frame.size.width, height: 50))
        peaceLabel.text = "Peace."
        peaceLabel.textAlignment = .center
        peaceLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(fontSize))
        peaceLabel.textColor = UIColor.white
        peaceLabel.animation = "fadeIn"
        peaceLabel.duration = 2
        // Animate after 0.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.peaceLabel.animate()
            self.view.addSubview(self.peaceLabel)
        }
    }
    
    func addBodyText() {
        var y: Int
        var fontSize: Int
        
        if device.isOneOf(iPadsThatNeedAdjusting) {
            y = 145
            fontSize = 16
        } else {
            y = device.isOneOf(iphonesThatNeedAdjusting) ? 230 : 320
            fontSize = device.isOneOf(iphonesThatNeedAdjusting) ? 18 : 20
        }
        bodyText = SpringLabel(frame: CGRect(x: 0, y: (navigationController?.navigationBar.frame.origin.y)! + CGFloat(y), width: view.frame.size.width, height: 50))
        bodyText.text = "Enjoy money mindfulness"
        bodyText.textAlignment = .center
        bodyText.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        bodyText.textColor = UIColor.white
        bodyText.animation = "fadeIn"
        bodyText.duration = 2
        // Animate after 0.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.bodyText.animate()
            self.view.addSubview(self.bodyText)
        }
    }
    
    // https://github.com/cruisediary/Pastel
    func getAnimatedGradientBackground() -> PastelView {
        let pastelView = PastelView(frame: view.bounds)
        pastelView.startPastelPoint = .bottomRight
        pastelView.endPastelPoint = .topLeft
        
        pastelView.animationDuration = 3.0
        
        pastelView.setColors([
            UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1),    // pink
            UIColor(red:0.99, green:0.89, blue:0.54, alpha:1.0)             // yellow
            ])
        
        pastelView.startAnimation()
        
        return pastelView
    }
}
