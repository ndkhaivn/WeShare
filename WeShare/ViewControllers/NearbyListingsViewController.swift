//
//  NearbyListingsViewController.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 24/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

// This ViewController listens for database listing changes
class NearbyListingsViewController: UIViewController, DatabaseListener {
    var listenerType: ListenerType = .listings
    
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var tableView: UITableView!
    var nearbyListings: [Listing] = [] // list of nearby listings

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    func onListingsChange(change: DatabaseChange, listings: [Listing]) {
        nearbyListings = listings
        tableView.reloadData()
    }
    
    func onActivitiesChange(change: DatabaseChange, activities: [Activity]) {}
    
    // setup listener on view appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    // destroy listener on view appear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
}

// Implement required delegates
extension NearbyListingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyListings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let listingCell = tableView.dequeueReusableCell(withIdentifier: "listingCell", for: indexPath) as! ListingTableViewCell;
        let listing = nearbyListings[indexPath.row]
        // Get the color based on the type of listing (giving or asking)
        let color = UIColor.givingColor(giving: listing.giving!)
        listingCell.listingTitle?.text = listing.title;
        listingCell.listingTitle?.textColor = color;
        listingCell.listingProgress.progressTintColor = color;
        listingCell.listingProgress.progress = Float((listing.remaining)!)/Float(((listing.quantity)!))
        
        // Set the left icon for the listing
        let imageView = UIImageView(frame: CGRect(x: 12, y: 12, width: 26, height: 26))
        imageView.image = UIImage(systemName: (listing.category?.systemIcon!)!)
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = color
        listingCell.listingIcon?.layer.cornerRadius = 25
        listingCell.listingIcon?.layer.borderColor = color.cgColor
        listingCell.listingIcon?.layer.borderWidth = 3
        listingCell.listingIcon?.addSubview(imageView)

        return listingCell
    }
    
    // On Select a listing, navigate to Listing Detail
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "listingDetailSegue", sender: nearbyListings[indexPath.row])
    }
    
    // Initialize destination with chosen listing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "listingDetailSegue" {
            let destination = segue.destination as! ListingDetailViewController
            destination.listing = sender as? Listing
        }
    }

}
