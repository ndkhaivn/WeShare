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

    var listing: Listing?
    @IBOutlet weak var imagesView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressText: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = listing?.title!
        progressText.text = "\(listing?.quantity! ?? 0) raised of \(listing?.quantity! ?? 0) \(listing?.unit! ?? "")"
        descriptionLabel.text = listing?.desc
        
        imagesView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 211)
        imagesView.contentSize = CGSize(width: view.frame.width * CGFloat((listing?.imageURLs?.count)!), height: 211)
        imagesView.isPagingEnabled = true
        
        for i in 0 ..< (listing?.imageURLs?.count)! {
            let storage = Storage.storage()
            let storageRef = storage.reference(forURL: (listing?.imageURLs?[i])!.absoluteString)
            storageRef.getData(maxSize: 100 * 1024 * 1024) { data, error in
                if error != nil {
                    print("Error fetching image from Firebase Storage")
                } else {
                    let image = UIImage(data: data!)
                    let imageView = UIImageView(image: image)
                    imageView.contentMode = .scaleAspectFit
                    imageView.frame = CGRect(x: self.view.frame.width * CGFloat(i), y: 0, width: self.view.frame.width, height: 211)
                    self.imagesView.addSubview(imageView)
                }
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
