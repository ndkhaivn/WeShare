//
//  DatabaseProtocol.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 26/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case listings
    case all
}

protocol DatabaseListener: AnyObject{
    var listenerType: ListenerType {get set}
    func onListingsChange(change: DatabaseChange, listings: [Listing])
}

protocol DatabaseProtocol: AnyObject {
    
    func addListing(listing: Listing) -> Listing
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
