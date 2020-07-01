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
    case activities
    case all
}

protocol DatabaseListener: AnyObject{
    var listenerType: ListenerType {get set}
    func onListingsChange(change: DatabaseChange, listings: [Listing])
    func onActivitiesChange(change: DatabaseChange, activities: [Activity])
}

protocol DatabaseProtocol: AnyObject {
    
    func addListing(listing: Listing) -> Listing
    func getListing(withID id: String) -> Promise<Listing>
    
    func addListener(listener: DatabaseListener)
    
    func getCurrentUser() -> User
    
    func getUser(withUID uid: String) -> Promise<User>
    func getUser(withID id: String) -> Promise<User>
    
    func getUserReference(uid: String) -> Promise<DocumentReference>
    
    func getConversation(listingID: String, userID: String, hostID: String, name: String) -> Promise<Conversation>
    
    func getConversations(userID: String) -> Promise<[Conversation]>
    
    func addActivity(requestUser: User, quantity: Int, listing: Listing)
    func acceptActivity(activity: Activity, accepted: Bool)
    
    func uploadImage(image: UIImage) -> Promise<URL>
    
    func signIn(email: String, password: String) -> Promise<Bool>
    func signUp(email: String, password: String, name: String, phoneNo: String) -> Promise<Bool>
    func resetPassword(email: String) -> Promise<Bool>
    
    func removeListener(listener: DatabaseListener)
}
