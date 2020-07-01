//
//  LoginViewController.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 25/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, DatabaseListener {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    weak var databaseController: DatabaseProtocol?
    
    var listenerType: ListenerType = .listings

    func onListingsChange(change: DatabaseChange, listings: [Listing]) {
        print(listings)
    }
    func onActivitiesChange(change: DatabaseChange, activities: [Activity]) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailField.setLeftIcon(systemName: "envelope")
        passwordField.setLeftIcon(systemName: "lock.open")
        
        self.modalPresentationStyle = .fullScreen
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    @IBAction func login(_ sender: Any) {
        let email = emailField.text!
        let password = passwordField.text!
        
        databaseController?.signIn(email: email, password: password).then{ result in
            self.performSegue(withIdentifier: "loginSuccessfully", sender: nil)
        }.catch({ error in
            self.showAlert(title: "Login Error", message: error.localizedDescription)
        })
    }

}

