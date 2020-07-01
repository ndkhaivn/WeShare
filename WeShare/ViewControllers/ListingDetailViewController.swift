//
//  ListingDetailViewController.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 29/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import FirebaseStorage

class ListingDetailViewController: UIViewController {

    weak var databaseController: DatabaseProtocol?
    
    var listing: Listing?
    @IBOutlet weak var imagesView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressText: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var hostName: UILabel!
    @IBOutlet weak var hostAvatar: UIImageView!
    @IBOutlet weak var location: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        let color = UIColor.givingColor(giving: (listing?.giving)!)
        
        titleLabel.textColor = color
        progressText.textColor = color
        progressView.progressTintColor = color
        
        titleLabel.text = listing?.title!
        progressText.text = "Remaining: \(listing?.remaining! ?? 0)/\(listing?.quantity! ?? 0) \(listing?.unit! ?? "")"
        descriptionLabel.text = listing?.desc
        hostName.text = listing?.host!.name
        progressView.progress = Float((listing?.remaining)!)/Float(((listing?.quantity)!))
        
        let levels = listing?.address?.split(separator: ",")
        let shortLocation = levels![1] // Extract the Suburb section from full address
        location.text = String(shortLocation)
        
        imagesView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 211)
        imagesView.contentSize = CGSize(width: view.frame.width * CGFloat((listing?.imageURLs?.count)!), height: 211)
        imagesView.isPagingEnabled = true
        
        for i in 0 ..< (listing?.imageURLs?.count)! {
            databaseController?.getImage(url: (listing?.imageURLs?[i])!).then { image in
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFit
                imageView.frame = CGRect(x: self.view.frame.width * CGFloat(i), y: 0, width: self.view.frame.width, height: 211)
                self.imagesView.addSubview(imageView)
            }
        }
    }
    
    @IBAction func request(_ sender: Any) {
        
        let currentUser = databaseController?.getCurrentUser()
        if (currentUser?.id == listing?.host?.id) {
            self.showAlert(title: "Warning", message: "You can't request your listing")
            return
        }
        
        let alert = UIAlertController(title: "Request", message: "Enter the quantity (\((listing?.remaining!)!) remaining)", preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            let currentUser = self.databaseController?.getCurrentUser()
            self.databaseController?.addActivity(requestUser: currentUser!, quantity: Int(textField!.text!) ?? 0, listing: self.listing!)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func callHost(_ sender: Any) {
        let phoneNo = listing?.host!.phoneNo
        if let url = URL(string: "tel://\(phoneNo!)") {
            print(url)
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func smsHost(_ sender: Any) {
        let phoneNo = listing?.host!.phoneNo
        if let url = URL(string: "sms:\(phoneNo!)") {
            print(url)
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func chatHost(_ sender: Any) {
        
        let currentUser = databaseController?.getCurrentUser()
        if (currentUser?.id == listing?.host?.id) {
            self.showAlert(title: "Warning", message: "You can't message yourself")
            return
        }
        databaseController?.getConversation(listingID: listing!.id!, userID: (currentUser?.id)!, hostID: (listing?.host?.id)!, name: (listing?.title)!).then { conversation in
            print(conversation)
            let user = self.databaseController?.getCurrentUser()
            self.performSegue(withIdentifier: "chatSegue", sender: conversation)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print(sender)
        if segue.identifier == "chatSegue" {
            let sender = sender as! Conversation
            let destination = segue.destination as! ChatViewController
            destination.conversation = sender
        }
    }
    

}
