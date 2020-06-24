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
    
    func getCurrentUser() -> User
    func getUser(withUID uid: String) -> Promise<User>
    func getUser(withID id: String) -> Promise<User>
    
    func getUserReference(uid: String) -> Promise<DocumentReference>
    
    func getConversation(listingID: String, userID: String, hostID: String, name: String) -> Promise<Conversation>
    
    func getConversations(userID: String) -> Promise<[Conversation]>
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void)
    
    func removeListener(listener: DatabaseListener)
}
