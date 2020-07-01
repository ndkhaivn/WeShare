//
//  TextFieldExtensions.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 25/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    func setLeftIcon(systemName icon: String) {
        let image = UIImage(systemName: icon)
        let imageView = UIImageView(frame: CGRect(x: 10, y: 5, width: 30, height: 20))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        
        let containerView: UIView = UIView(frame: CGRect(x: 20, y: 0, width: 40, height: 30))
        containerView.addSubview(imageView)
        
        self.leftView = containerView
        self.leftViewMode = .always
    }
}
