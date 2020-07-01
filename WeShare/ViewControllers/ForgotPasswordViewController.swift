//
//  ForgotPasswordViewController.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 1/7/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

// Forgot Password Screen
class ForgotPasswordViewController: UIViewController {

    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        let email = emailField.text
        databaseController?.resetPassword(email: email!).then{ status in
            // if successful, display a success message
            self.showAlert(title: "Success", message: "An email has been sent to \(email!).\n Please check your inbox.")
        }.catch{ error in
            // otherwise, display an error
            self.showAlert(title: "Error", message: error.localizedDescription)
        }
        
    }

}
