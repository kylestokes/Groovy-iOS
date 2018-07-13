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
    let devicesThatNeedAdjusting = [Device.iPhone4, Device.iPhone4s, Device.iPhone5, Device.iPhone5s, Device.iPhone5c, Device.iPhoneSE, Device.simulator(Device.iPhone5s), Device.simulator(Device.iPhoneSE)]
    
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
        
        self.peaceLabel.animation = "fadeOut"
        self.peaceLabel.animate()
        
        self.bodyText.animation = "fadeOut"
        self.bodyText.animate()
    }
    
    func getDevice() {
        // If device is in 'devicesThatNeedAdjusting', the peace and body text on this view will be removed
        device = Device()
    }
    
    
    func addLavaLampIcon() {
        let peaceHandOriginal = UIImage(named: "lava")
        // apply color to peace image
        // https://stackoverflow.com/a/27163581
        let peaceHandGradient = peaceHandOriginal?.withRenderingMode(.alwaysTemplate)
        imageView = SpringImageView(image: peaceHandGradient)
        imageView.tintColor = UIColor.white
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 20, y: (navigationController?.navigationBar.frame.origin.y)! + 50, width: view.frame.size.width - 40, height: 200)
        imageView.animation = "fadeInUp"
        imageView.duration = 2
        imageView.animate()
        self.view.addSubview(imageView)
    }
    
    func addPeaceText() {
        if !device.isOneOf(devicesThatNeedAdjusting) {
            peaceLabel = SpringLabel(frame: CGRect(x: 0, y: (navigationController?.navigationBar.frame.origin.y)! + 270, width: view.frame.size.width, height: 50))
            peaceLabel.text = "Peace."
            peaceLabel.textAlignment = .center
            peaceLabel.font = UIFont.boldSystemFont(ofSize: 50)
            peaceLabel.textColor = UIColor.white
            peaceLabel.animation = "fadeIn"
            peaceLabel.duration = 2
            // Animate after 0.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.peaceLabel.animate()
                self.view.addSubview(self.peaceLabel)
            }
        }
    }
    
    func addBodyText() {
        if !device.isOneOf(devicesThatNeedAdjusting) {
            bodyText = SpringLabel(frame: CGRect(x: 0, y: (navigationController?.navigationBar.frame.origin.y)! + 320, width: view.frame.size.width, height: 50))
            bodyText.text = "Enjoy money mindfulness"
            bodyText.textAlignment = .center
            bodyText.font = UIFont.systemFont(ofSize: 20)
            bodyText.textColor = UIColor.white
            bodyText.animation = "fadeIn"
            bodyText.duration = 2
            // Animate after 0.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.bodyText.animate()
                self.view.addSubview(self.bodyText)
            }
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
