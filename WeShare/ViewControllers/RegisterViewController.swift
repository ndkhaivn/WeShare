//
//  RegisterViewController.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 1/7/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        emailField.setLeftIcon(systemName: "envelope")
        nameField.setLeftIcon(systemName: "person")
        phoneField.setLeftIcon(systemName: "phone")
        passwordField.setLeftIcon(systemName: "lock.open")
    }
    

    @IBAction func register(_ sender: Any) {
        
        let email = emailField.text
        let name = nameField.text
        let phone = phoneField.text
        let password = passwordField.text
        
        databaseController?.signUp(email: email!, password: password!, name: name!, phoneNo: phone!)
        .then{ status in
            let alert = UIAlertController(title: "Registered Successfully", message: "You can login now", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                self.dismiss(animated: true, completion: nil)
            }))

            self.present(alert, animated: true)
        }.catch({ error in
            self.showAlert(title: "Error", message: error.localizedDescription)
        })
        
    }
    

}
