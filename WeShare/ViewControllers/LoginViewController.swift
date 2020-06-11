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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailField.setLeftIcon(systemName: "person")
        passwordField.setLeftIcon(systemName: "lock")
        
        self.modalPresentationStyle = .fullScreen
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Do any additional setup after loading the view.
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
        
        databaseController?.signIn(email: email, password: password) { loginStatus in
            if (!loginStatus) {
                let errorMessage = "Incorrect email or password. \nPlease try again."
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.performSegue(withIdentifier: "loginSuccessfully", sender: nil)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

