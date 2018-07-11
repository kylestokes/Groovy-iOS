//
//  PasswordSignUpViewController.swift
//  groovy
//
//  Created by Kyle Stokes on 7/2/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit
import FirebaseUI

class PasswordSignUpViewController: FUIPasswordSignUpViewController {
    
    var emailTextField = UITextField()
    var passwordTextField = UITextField()
    var userNameTextField = UITextField()
    let showPassword = UIButton(type: .custom)
    var userEmail: String!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserEmail()
        addEmailTextField()
        addUserNameTextField()
        addPasswordTextField()
        addBarButtons()
        didChangeEmail(emailTextField.text!, orPassword: passwordTextField.text!, orUserName: userNameTextField.text!)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        didChangeEmail(emailTextField.text!, orPassword: passwordTextField.text!, orUserName: userNameTextField.text!)
    }
    
    @objc func saveSelected() {
        userNameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        signUp(withEmail: emailTextField.text!, andPassword: passwordTextField.text!, andUsername: userNameTextField.text!)
    }
    
    // Get email from UserDefaults
    func getUserEmail() {
        if let email = UserDefaults.standard.value(forKey: "userEmail") as? String {
            userEmail = email
        }
    }
    
    @objc func togglePassword() {
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
        if passwordTextField.isSecureTextEntry {
            showPassword.setImage(#imageLiteral(resourceName: "eye"), for: .normal)
        } else {
            showPassword.setImage(#imageLiteral(resourceName: "eye-dark"), for: .normal)
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
        self.view.addSubview(emailTextField)
        emailTextField.isEnabled = false
    }
    
    func addUserNameTextField() {
        userNameTextField = UITextField(frame: CGRect(x: 20, y: (navigationController?.navigationBar.frame.origin.y)! + 160, width: view.frame.size.width - 40, height: 40))
        userNameTextField.placeholder = "First & last name"
        userNameTextField.font = UIFont.systemFont(ofSize: 15)
        userNameTextField.borderStyle = UITextBorderStyle.roundedRect
        userNameTextField.autocorrectionType = UITextAutocorrectionType.yes
        userNameTextField.keyboardType = UIKeyboardType.default
        userNameTextField.returnKeyType = UIReturnKeyType.next
        userNameTextField.clearButtonMode = UITextFieldViewMode.whileEditing;
        userNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        self.view.addSubview(userNameTextField)
        userNameTextField.becomeFirstResponder()
        userNameTextField.delegate = self
    }
    
    func addPasswordTextField() {
        passwordTextField = UITextField(frame: CGRect(x: 20, y: (navigationController?.navigationBar.frame.origin.y)! + 205, width: view.frame.size.width - 40, height: 40))
        passwordTextField.placeholder = "Choose password"
        passwordTextField.font = UIFont.systemFont(ofSize: 15)
        passwordTextField.borderStyle = UITextBorderStyle.roundedRect
        passwordTextField.autocorrectionType = UITextAutocorrectionType.no
        passwordTextField.isSecureTextEntry = true
        passwordTextField.rightViewMode = .always
        passwordTextField.keyboardType = UIKeyboardType.default
        passwordTextField.returnKeyType = UIReturnKeyType.done
        passwordTextField.clearButtonMode = UITextFieldViewMode.whileEditing;
        passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.delegate = self
        
        // Add 'eye' to toggle password
        showPassword.setImage(#imageLiteral(resourceName: "eye"), for: .normal)
        showPassword.imageEdgeInsets = UIEdgeInsetsMake(0, -16, 0, 0)
        showPassword.frame = CGRect(x: CGFloat(passwordTextField.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        showPassword.imageView?.contentMode = .scaleAspectFit
        showPassword.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)
        passwordTextField.rightView = showPassword
        
        self.view.addSubview(passwordTextField)
    }
    
    func addBarButtons() {
        // 'Save' bar button
        let save = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveSelected))
        navigationItem.rightBarButtonItem = save
        navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        
        // Adjust 'Save' button according to passwordTextField's values
        save.isEnabled = false
        
        navigationItem.backBarButtonItem?.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        navigationItem.backBarButtonItem?.title = ""
    }
    
}

extension PasswordSignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.placeholder == "First & last name" {
            passwordTextField.becomeFirstResponder()
        } else {
            passwordTextField.resignFirstResponder()
            signUp(withEmail: emailTextField.text!, andPassword: passwordTextField.text!, andUsername: userNameTextField.text!)
        }
        return true
    }
}
