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
    var remaining: Int?
    var giving: Bool?
    var unit: String?
    var address: String?
    var desc: String?
    var iconName: String?
    var location: [Double]?
    var imageURLs: [URL]?
    var host: User?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case category
        case quantity
        case remaining
        case unit
        case giving
        case address
        case desc
        case iconName
        case location
        case imageURLs
    }
}
