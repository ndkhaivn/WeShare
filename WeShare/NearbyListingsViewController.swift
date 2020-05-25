//
//  NearbyListingsViewController.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 24/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class NearbyListingsViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    var nearbyListings: [String] = ["Hand Sanitizer", "Toilet paper", "Food"];

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
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
        return 3
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let listingCell = tableView.dequeueReusableCell(withIdentifier: "listingCell", for: indexPath) as! ListingTableViewCell;
        listingCell.listingTitle?.text = nearbyListings[indexPath.row];

        return listingCell
    }
    
    
}
