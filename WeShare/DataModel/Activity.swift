//
//  Activity.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 24/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation

class Activity: NSObject {
    var id: String
    var hostUser: User
    var requestUser: User
    var accepted: Bool?
    var acceptedOn: Date?
    var quantity: Int
    var listing: Listing?
    
    init(id: String, hostUser: User, requestUser: User, accepted: Bool?, acceptedOn: Date?, quantity: Int, listing: Listing?) {
        self.id = id
        self.hostUser = hostUser
        self.requestUser = requestUser
        self.accepted = accepted
        self.acceptedOn = acceptedOn
        self.quantity = quantity
        self.listing = listing
    }
}
