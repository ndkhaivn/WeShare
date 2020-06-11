//
//  AddressSuggestion.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 11/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation
import SearchTextField
import MapKit

class AddressSuggestion: SearchTextFieldItem {
    
    var completion: MKLocalSearchCompletion?
    
    public init(title: String, completion: MKLocalSearchCompletion) {
        super.init(title: title)
        self.completion = completion
    }
}
