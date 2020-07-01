//
//  ActivityDetailViewController.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 30/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import FBSDKShareKit
import UIKit
import Firebase
import Promises

class ActivityDetailViewController: UIViewController, SharingDelegate {

    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var listingIcon: UIView!
    @IBOutlet weak var listingTitle: UILabel!
    @IBOutlet weak var activityDate: UILabel!
    
    @IBOutlet weak var giverImage: UIImageView!
    @IBOutlet weak var giverName: UILabel!
    @IBOutlet weak var takerImage: UIImageView!
    @IBOutlet weak var takerName: UILabel!
    
    var activity: Activity?
    var shareText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        let giver: User
        let taker: User
        
        if (activity!.listing.giving == true) {
            giver = activity!.hostUser
            taker = activity!.requestUser
        } else {
            giver = activity!.requestUser
            taker = activity!.hostUser
        }
        
        giverName.text = giver.name
        takerName.text = taker.name
        listingTitle.text = "\((activity!.listing.title)!) x\(activity!.quantity)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        let formattedDate = formatter.string(from: activity!.acceptedOn!)
        activityDate.text = formattedDate
        
        shareText = "\((giver.name)!) shares [\((listingTitle.text)!)] with \((takerName.text)!)"
        
        let imageView = UIImageView(frame: CGRect(x: 12, y: 12, width: 26, height: 26))
        imageView.image = UIImage(systemName: (activity!.listing.category?.systemIcon!)!)
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .systemTeal
    
        listingIcon?.layer.cornerRadius = 25
        listingIcon?.layer.borderColor = UIColor.white.cgColor
        listingIcon?.layer.borderWidth = 3
        listingIcon?.addSubview(imageView)
    }
    
    @IBAction func shareOnFacebook(_ sender: Any) {
        
        let screenshot = self.view.takeScreenshot()
        
        databaseController?.uploadImage(image: screenshot).then { url in
            let shareContent = ShareLinkContent()
            shareContent.contentURL = URL.init(string: url.absoluteString)!
            shareContent.quote = self.shareText
            ShareDialog(fromViewController: self, content: shareContent, delegate: self).show()
        }
    }
    
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        if sharer.shareContent.pageID != nil {
            print("Share: Success")
        }
    }
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        print("Share: Fail")
    }
    func sharerDidCancel(_ sharer: Sharing) {
        print("Share: Cancel")
    }
}

extension UIView {
    
    func takeScreenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if image != nil {
            return image!
        }
        
        return UIImage()
    }
    
}
