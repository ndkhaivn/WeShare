//
//  ActivityDetailViewController.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 30/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class ActivityDetailViewController: UIViewController {

    @IBOutlet weak var listingIcon: UIView!
    @IBOutlet weak var listingTitle: UILabel!
    @IBOutlet weak var activityDate: UILabel!
    
    @IBOutlet weak var giverImage: UIImageView!
    @IBOutlet weak var giverName: UILabel!
    @IBOutlet weak var takerImage: UIImageView!
    @IBOutlet weak var takerName: UILabel!
    
    var activity: Activity?
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        activityDate.text = formatter.string(from: activity!.acceptedOn!)
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
