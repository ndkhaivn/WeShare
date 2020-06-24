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
    var uid: String?
    var name: String?
    var phoneNo: String?
    var avatarURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case uid
        case name
        case phoneNo
        case avatarURL
    }
}
