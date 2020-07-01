//
//  ProfileViewController.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 1/7/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var avatar: UIImageView!
    var imagePicker = UIImagePickerController()
    
    weak var databaseController: DatabaseProtocol?
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        tableView.dataSource = self
        tableView.delegate = self
        
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = true
        
        avatar.initAvatarFrame()
        
        user = databaseController!.getCurrentUser()
        
        if (user?.avatarURL != nil) {
            databaseController?.getImage(url: user!.avatarURL!).then { image in
                self.avatar.image = image
            }
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        databaseController?.signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeAvatar(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let img = info[.originalImage] as? UIImage{
            databaseController?.uploadImage(image: img).then { url in
                self.avatar.image = img
                self.user?.avatarURL = url
                self.databaseController?.updateUser(id: (self.user?.id)!, key: "avatarURL", value: url.absoluteString).then { result in
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
        
        switch (indexPath.row) {
        case 0:
            cell.textLabel?.text = "Name"
            cell.detailTextLabel?.textColor = .secondaryLabel
            cell.detailTextLabel?.text = user!.name
            return cell
        case 1:
            cell.textLabel?.text = "Phone No."
            cell.detailTextLabel?.textColor = .secondaryLabel
            cell.detailTextLabel?.text = user!.phoneNo
            return cell
        default:
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            
            let alert = UIAlertController(title: "Enter name", message: "", preferredStyle: .alert)
            alert.addTextField()
            let textField = alert.textFields![0]
            textField.text = user?.name
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                if (textField.text == nil || textField.text!.isEmpty) {
                    self.showAlert(title: "Error", message: "Please enter a valid name")
                } else {
                    self.user?.name = textField.text!
                    self.tableView.reloadData()
                    self.databaseController?.updateUser(id: (self.user?.id)!, key: "name", value: textField.text!)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

            self.present(alert, animated: true, completion: nil)
        }
        
        if indexPath.row == 1 {
            
            let alert = UIAlertController(title: "Enter Phone No.", message: user?.phoneNo, preferredStyle: .alert)
            alert.addTextField()
            let textField = alert.textFields![0]
            textField.text = user?.phoneNo
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                if (textField.text == nil || textField.text!.isEmpty) {
                    self.showAlert(title: "Error", message: "Please enter a valid phone no.")
                } else {
                    self.user?.phoneNo = textField.text!
                    self.tableView.reloadData()
                    self.databaseController?.updateUser(id: (self.user?.id)!, key: "phoneNo", value: textField.text!)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

            self.present(alert, animated: true, completion: nil)
            
        }
    }

}
