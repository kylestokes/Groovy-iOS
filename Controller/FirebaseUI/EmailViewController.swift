//
//  EmailViewController.swift
//  groovy
//
//  Created by Kyle Stokes on 6/30/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit
import FirebaseUI

class EmailViewController: FUIEmailEntryViewController {
    
    var emailTextField = UITextField()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Email"
        
        addEmailTextField()
        addBarButtons()
        
        // Adjust 'Next' button according to emailTextField's values
        didChangeEmail(emailTextField.text!)
    }
    
    func addEmailTextField() {
        emailTextField = UITextField(frame: CGRect(x: 20, y: (navigationController?.navigationBar.frame.origin.y)! + 115, width: view.frame.size.width - 40, height: 40))
        emailTextField.placeholder = "Email"
        emailTextField.font = UIFont.systemFont(ofSize: 15)
        emailTextField.borderStyle = UITextBorderStyle.roundedRect
        emailTextField.autocorrectionType = UITextAutocorrectionType.no
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        emailTextField.returnKeyType = UIReturnKeyType.next
        emailTextField.clearButtonMode = UITextFieldViewMode.whileEditing;
        emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        emailTextField.becomeFirstResponder()
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        self.view.addSubview(emailTextField)
        emailTextField.delegate = self
    }
    
    func addBarButtons() {
        let next = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextSelected))
        navigationItem.rightBarButtonItem = next
        navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        next.isEnabled = false
        
        navigationItem.backBarButtonItem?.tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        navigationItem.backBarButtonItem?.title = ""
    }
    
    // https://stackoverflow.com/a/28395000
    @objc func textFieldDidChange(_ textField: UITextField) {
        didChangeEmail(textField.text!)
    }
    
    @objc func nextSelected() {
        saveEmail()
        onNext(emailTextField.text!)
    }
    
    // Save email address to UserDefaults
    func saveEmail() {
        UserDefaults.standard.set(emailTextField.text, forKey: "userEmail")
    }
}

extension EmailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveEmail()
        onNext(textField.text!)
        return true
    }
}
