//
//  CustomColors.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 1/7/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    static let GIVING = UIColor.systemGreen
    static let ASKING = UIColor.systemOrange
    
    static func givingColor(giving: Bool) -> UIColor {
        if (giving) {
            return GIVING
        } else {
            return ASKING
        }
    }
}
