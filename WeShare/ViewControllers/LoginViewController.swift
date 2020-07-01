//
//  LoginViewController.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 25/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import Firebase

// Login Screen (including Register - Forgot Password buttons)
class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize Text Inputs
        emailField.setLeftIcon(systemName: "envelope")
        passwordField.setLeftIcon(systemName: "lock.open")
        
        // After login, redirect fullscreen to Home Screen
        self.modalPresentationStyle = .fullScreen
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }

    @IBAction func login(_ sender: Any) {
        let email = emailField.text!
        let password = passwordField.text!
        
        databaseController?.signIn(email: email, password: password).then{ result in
            // if login successfully, redirect to Home Screen
            self.performSegue(withIdentifier: "loginSuccessfully", sender: nil)
        }.catch({ error in
            // otherwise, display error message
            self.showAlert(title: "Login Error", message: error.localizedDescription)
        })
    }

}

