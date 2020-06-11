//
//  MapAnnotation.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 27/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import MapKit

class MapAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var systemIconName: String?
    var listing: Listing?
    
    init(title: String, subtitle: String, lat: Double, lng: Double, iconName: String, listing: Listing) {
        self.title = title
        self.subtitle = subtitle
        self.systemIconName = iconName
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        self.listing = listing
    }
}
