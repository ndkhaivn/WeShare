//
//  ListingTableViewCell.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 22/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class ListingTableViewCell: UITableViewCell {


    @IBOutlet weak var listingTitle: UILabel!
    @IBOutlet weak var listingIcon: UIView!
    @IBOutlet weak var listingProgress: UIProgressView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
