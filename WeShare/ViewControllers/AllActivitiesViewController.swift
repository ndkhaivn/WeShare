//
//  AllActivitiesViewController.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 30/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class AllActivitiesViewController: UITableViewController, DatabaseListener {

    var listenerType: ListenerType = .activities
    
    weak var databaseController: DatabaseProtocol?
    var activities: [Activity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    func onListingsChange(change: DatabaseChange, listings: [Listing]) {}
    
    func onActivitiesChange(change: DatabaseChange, activities: [Activity]) {
        self.activities = activities
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    // Automatically determine the user and the direction
    // Sample: From John Doe
    func userTakeGive(activity: Activity) -> String {
        var name = ""
        var action = ""
        let currentUser = databaseController?.getCurrentUser()
        if (activity.hostUser.id == currentUser?.id) {
            name = activity.requestUser.name!
            if ((activity.listing.giving)!) {
                action = "To"
            } else {
                action = "From"
            }
        } else {
            name = activity.hostUser.name!
            if ((activity.listing.giving)!) {
                action = "From"
            } else {
                action = "To"
            }
        }
        return "\(action) \(name)"
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! ActivityViewCell
        
        let activity = activities[indexPath.row]
        // Each cell has an avatar
        cell.avatar.initAvatarFrame()
        // Title
        cell.userLabel.text = userTakeGive(activity: activity)
        // The item
        cell.itemLabel.text = "\((activity.listing.title)!) x\(activity.quantity)"
        if (activity.accepted == nil) {
            cell.pendingTag.text = "Pending"
            cell.pendingTag.textColor = .systemGray
        } else if (activity.accepted == true) {
            cell.pendingTag.text = "Accepted"
            cell.pendingTag.textColor = .systemGreen
        } else {
            cell.pendingTag.text = "Declined"
            cell.pendingTag.textColor = .systemRed
        }
        
        if (activity.requestUser.avatarImage != nil) {
            cell.avatar.image = activity.requestUser.avatarImage
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (activities[indexPath.row].accepted == true) {
            performSegue(withIdentifier: "activityDetail", sender: activities[indexPath.row])
        }
    }

    // Setup trailing actions (Accept/Decline) the request
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Accept button with green background
        let accept = UIContextualAction(style: .normal, title: "Accept") { (action, view, completionHandler) in
            completionHandler(true)
            self.databaseController?.acceptActivity(activity: self.activities[indexPath.row], accepted: true)
        }
        accept.backgroundColor = .systemGreen
        
        // Decline button with red background
        let decline = UIContextualAction(style: .normal, title: "Decline") { (action, view, completionHandler) in
            completionHandler(true)
            self.databaseController?.acceptActivity(activity: self.activities[indexPath.row], accepted: false)
        }
        decline.backgroundColor = .systemRed
        
        let swipe = UISwipeActionsConfiguration(actions: [decline, accept])
        return swipe
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let activity = activities[indexPath.row]
        return (activity.accepted == nil) && (activity.hostUser.id == databaseController?.getCurrentUser().id)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "activityDetail") {
            let destination = segue.destination as! ActivityDetailViewController
            destination.activity = (sender as! Activity)
        }
        
    }
    

}
