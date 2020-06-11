//
//  User.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 26/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation

class User: NSObject, Codable {
    var id: String?
    var name: String?
    var phoneNo: String?
    var avatar: URL?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case phoneNo
        case avatar
    }
}
