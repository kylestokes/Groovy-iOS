//
//  PasswordRecoveryViewController.swift
//  groovy
//
//  Created by Kyle Stokes on 7/5/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit
import FirebaseUI

class PasswordRecoveryViewController: FUIPasswordRecoveryViewController {
    
    var emailTextField = UITextField()
    var userEmail: String!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.viewDidLoad()
        
        getUserEmail()
        addEmailTextField()
        addInstructionsLabel()
        
        // Add 'X' in place of 'Back' button
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "close"), style: .done, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        
        // Add 'Send'
        let send = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendPasswordVerificationEmail))
        navigationItem.rightBarButtonItem = send
        navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        
        didChangeEmail(emailTextField.text!)
    }
    
    // Get email from UserDefaults
    func getUserEmail() {
        if let email = UserDefaults.standard.value(forKey: "userEmail") as? String {
            userEmail = email
        }
    }
    
    func addEmailTextField() {
        emailTextField = UITextField(frame: CGRect(x: 20, y: (navigationController?.navigationBar.frame.origin.y)! + 115, width: view.frame.size.width - 40, height: 40))
        emailTextField.placeholder = "Email"
        emailTextField.text = userEmail
        emailTextField.font = UIFont.systemFont(ofSize: 15)
        emailTextField.borderStyle = UITextBorderStyle.roundedRect
        emailTextField.autocorrectionType = UITextAutocorrectionType.no
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        emailTextField.returnKeyType = UIReturnKeyType.next
        emailTextField.clearButtonMode = UITextFieldViewMode.whileEditing;
        emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        emailTextField.becomeFirstResponder()
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        emailTextField.delegate = self
        self.view.addSubview(emailTextField)
    }
    
    func addInstructionsLabel() {
        let instructionsLabel = UILabel(frame: CGRect(x: 20, y: (navigationController?.navigationBar.frame.origin.y)! + 160, width: view.frame.size.width - 40, height: 50))
        instructionsLabel.text = "Get instructions sent to this email that explain how to reset your password."
        instructionsLabel.font = UIFont.systemFont(ofSize: 12)
        instructionsLabel.textColor = UIColor.gray
        instructionsLabel.numberOfLines = 2
        instructionsLabel.lineBreakMode = .byWordWrapping
        self.view.addSubview(instructionsLabel)
    }
    
    @objc func goBack() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func sendPasswordVerificationEmail() {
        emailTextField.resignFirstResponder()
        recoverEmail(emailTextField.text!)
        // https://stackoverflow.com/a/38031138
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.goBack()
        }
    }
    
    @objc func textFieldDidChange() {
        didChangeEmail(emailTextField.text!)
    }
}

extension PasswordRecoveryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        recoverEmail(emailTextField.text!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.goBack()
        }
        return true
    }
}
