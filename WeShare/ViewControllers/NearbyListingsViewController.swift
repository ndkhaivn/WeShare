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
        nearbyListings = listings
        tableView.reloadData()
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
        listingCell.listingTitle?.text = nearbyListings[indexPath.row].title;

        return listingCell
    }
    
    
}
