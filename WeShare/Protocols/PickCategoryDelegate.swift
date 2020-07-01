//
//  PickCategoryDelegate.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 29/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

protocol PickCategoryDelegate: AnyObject {
    
    // Delegate picking category to a different TableViewController
    func pickCategory(category: Category)
    
}
