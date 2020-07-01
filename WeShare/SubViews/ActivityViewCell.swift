//
//  ActivityViewCell.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 30/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class ActivityViewCell: UITableViewCell {

    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var pendingTag: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
