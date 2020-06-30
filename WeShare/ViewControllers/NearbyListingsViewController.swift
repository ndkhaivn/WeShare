//
//  NearbyListingsViewController.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 24/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class NearbyListingsViewController: UIViewController, DatabaseListener {
    var listenerType: ListenerType = .listings
    
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var tableView: UITableView!
    var nearbyListings: [Listing] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    func onListingsChange(change: DatabaseChange, listings: [Listing]) {
        print("listing changed")
        nearbyListings = listings
        tableView.reloadData()
    }
    
    func onActivitiesChange(change: DatabaseChange, activities: [Activity]) {}
    
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

extension NearbyListingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyListings.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let listingCell = tableView.dequeueReusableCell(withIdentifier: "listingCell", for: indexPath) as! ListingTableViewCell;
        let listing = nearbyListings[indexPath.row]
        listingCell.listingTitle?.text = listing.title;
        
        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        imageView.image = UIImage(systemName: (listing.category?.systemIcon!)!)
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = UIColor.systemOrange
    
        listingCell.listingIcon?.layer.cornerRadius = 25
        listingCell.listingIcon?.layer.borderColor = UIColor.systemOrange.cgColor
        listingCell.listingIcon?.layer.borderWidth = 3
        listingCell.listingIcon?.addSubview(imageView)
        
        
//        print(UIImage(systemName: listing.iconName!))

        return listingCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "listingDetailSegue", sender: nearbyListings[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "listingDetailSegue" {
            let destination = segue.destination as! ListingDetailViewController
            destination.listing = sender as? Listing
        }
    }

}
