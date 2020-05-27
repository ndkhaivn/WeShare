//
//  Listing.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 26/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation

class Listing: NSObject, Codable {
    var id: String?
    var title: String?
    var category: Category?
    var quantity: Int?
    var unit: String?
    var address: String?
    var desc: String?
    var iconName: String?
    var location: [Double]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case category
        case quantity
        case unit
        case address
        case desc
        case iconName
        case location
    }
}
