//
//  ForgotPasswordViewController.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 1/7/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        let email = emailField.text
        databaseController?.resetPassword(email: email!).then{ status in
            self.showAlert(title: "Success", message: "An email has been sent to \(email!).\n Please check your inbox.")
        }.catch{ error in
            self.showAlert(title: "Error", message: error.localizedDescription)
        }
        
    }

}
