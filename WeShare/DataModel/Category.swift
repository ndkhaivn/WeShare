//
//  Category.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 26/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

class Category: Codable {
    var name: String?
    var systemIcon: String?
    
    init(name: String, systemIcon: String) {
        self.name = name
        self.systemIcon = systemIcon
    }
}
