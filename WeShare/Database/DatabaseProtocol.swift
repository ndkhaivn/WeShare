//
//  DatabaseProtocol.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 26/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Promises
import Firebase

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
    
    func getUser(uid: String) -> Promise<User>
    func getUserReference(uid: String) -> Promise<DocumentReference>
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void)
    
    func removeListener(listener: DatabaseListener)
}
