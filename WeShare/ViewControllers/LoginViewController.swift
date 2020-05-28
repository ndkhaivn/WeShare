//
//  LoginViewController.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 25/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, DatabaseListener {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    weak var databaseController: DatabaseProtocol?
    
//        databaseController?.addListing()
    
    
    var listenerType: ListenerType = .listings
    
    @IBAction func loginButton(_ sender: Any) {
    }
    
    
    func onListingsChange(change: DatabaseChange, listings: [Listing]) {
        print(listings)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailField.setLeftIcon(systemName: "person")
        
        
        
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

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

