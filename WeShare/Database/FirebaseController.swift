//
//  FirebaseController.swift
//  FIT3178-Lab04
//
//  Created by Nguyễn Đình Khải on 26/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Promises

class FirebaseController: NSObject, DatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    var listingsRef: CollectionReference?
    var activitiesRef: CollectionReference?
    var usersRef: CollectionReference?
    var conversationsRef: CollectionReference?
    var listings: [Listing]
    var activities: [Activity]
    var currentUser: User?
    
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        listings = [Listing]()
        activities = [Activity]()
        
        super.init()
    }
    
    // MARK:- Setup code for Firestore listeners
    func setUpListingListener() {
        listingsRef = database.collection("listings")
        listingsRef?.addSnapshotListener { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.parseListingsSnapshot(snapshot: querySnapshot)
        }
    }
    
    func setUpUsers() {
        usersRef = database.collection("users")
        self.getUser(withUID: (Auth.auth().currentUser?.uid)!).then { user in
            self.currentUser = user
            self.setUpActivitiesListener(hostID: user.id!)
        }
    }
    
    func setUpConversations() {
        conversationsRef = database.collection("conversations")
    }
    
    func setUpActivitiesListener(hostID: String) {
        activitiesRef = database.collection("activities")
        activitiesRef?.whereField("hostUser", isEqualTo: hostID).addSnapshotListener { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.parseActivitiesSnapshot(snapshot: querySnapshot)
        }
        
        activitiesRef?.whereField("requestUser", isEqualTo: hostID).addSnapshotListener { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.parseActivitiesSnapshot(snapshot: querySnapshot)
        }
    }

    
    func parseListingDocument(document: DocumentSnapshot) -> Listing? {
        var parsedListing: Listing?
        
        let listingID = document.documentID
        print(listingID)
        
        if let hostRef = document.data()!["host"] as? DocumentReference {
            
            getUser(withID: hostRef.documentID).then { (user) in
                parsedListing!.host = user
            }
        }
        
        do {
            parsedListing = try document.data(as: Listing.self)
        } catch {
            print("Unable to decode listing.")
            return nil
        }
        
        guard let listing = parsedListing else {
            print("Document doesn't exist")
            return nil
        }
        listing.id = listingID
        
        return listing
    }
    
    // MARK:- Parse Functions for Firebase Firestore responses
    func parseListingsSnapshot(snapshot: QuerySnapshot) {

        snapshot.documentChanges.forEach { (change) in
            
            guard let listing = parseListingDocument(document: change.document) else {
                return
            }
            
            if change.type == .added {
                listings.append(listing)
            }
            else if change.type == .modified {
                let index = getListingIndexByID(listing.id!)!
                listings[index] = listing
            }
            else if change.type == .removed {
                if let index = getListingIndexByID(listing.id!) {
                    listings.remove(at: index)
                }
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.listings ||
                listener.listenerType == ListenerType.all {
                print("invoking", listener)
                listener.onListingsChange(change: .update, listings: listings)
            }
        }
    }
    
    func parseActivitiesSnapshot(snapshot: QuerySnapshot) {

        snapshot.documentChanges.forEach { (change) in

            let activityID = change.document.documentID
            let document = change.document
            
            let hostUserID = document["hostUser"] as! String
            let requestUserID = document["requestUser"] as! String
            let quantity = document["quantity"] as! Int
            let accepted = document["accepted"] as? Bool
            let acceptedOn = document["acceptedOn"] as? Date
            let listingID = document["listing"] as! String
            
            all(
                getUser(withID: hostUserID),
                getUser(withID: requestUserID),
                getListing(withID: listingID)
            ).then { (hostUser, requestUser, listing) in
                let parsedActivity = Activity(id: activityID, hostUser: hostUser, requestUser: requestUser, accepted: accepted, acceptedOn: acceptedOn, quantity: quantity, listing: listing)
                
                if change.type == .added {
                    self.activities.append(parsedActivity)
                }
                else if change.type == .modified {
                    if let index = self.getActivityIndexByID(parsedActivity.id) {
                        self.activities[index] = parsedActivity
                    }
                }
                else if change.type == .removed {
                    if let index = self.getActivityIndexByID(parsedActivity.id) {
                        self.activities.remove(at: index)
                    }
                }
                
                self.listeners.invoke { (listener) in
                    if listener.listenerType == ListenerType.activities ||
                        listener.listenerType == ListenerType.all {
                        listener.onActivitiesChange(change: .update, activities: self.activities)
                    }
                }
                
            }
        }
    }
    
    // MARK:- Utility Functions
    func getListingIndexByID(_ id: String) -> Int? {
        if let listing = getListingByID(id) {
            return listings.firstIndex(of: listing)
        }
        return nil
    }
    
    func getListingByID(_ id: String) -> Listing? {
        for listing in listings {
            if listing.id == id {
                return listing
            }
        }
        return nil
    }
    
    func getActivityIndexByID(_ id: String) -> Int? {
        return activities.firstIndex(where: { $0.id == id })
    }
    
    // MARK:- Required Database Functions
    
    func addListing(listing: Listing) -> Listing {
        
        self.getUserReference(uid: (Auth.auth().currentUser?.uid)!).then { userRef in
         
            do {
                if let listingRef = try self.listingsRef?.addDocument(from: listing) {
                    listingRef.updateData(["host": userRef ])
                    listing.id = listingRef.documentID
                }
            } catch {
                print("Failed to serialize listing")
            }
            
        }
        
        return listing
    }
    
    
    func getListing(withID id: String) -> Promise<Listing> {
        return Promise { fulfill, reject in
            self.listingsRef?.document(id).getDocument{ (document, err) in
                if let err = err {
                    print("Error getting listing: \(err)")
                    reject(err)
                } else {
                    do {
                        let listing = self.parseListingDocument(document: document!)
                        fulfill(listing!)
                    } catch let error {
                        print("Error decoding listing")
                        reject(error)
                    }
                }
            }
            
        }
    }
    
    func getUser(withUID uid: String) -> Promise<User> {
        // TODO: user with uid not found
        return Promise { fulfill, reject in
            self.usersRef?.whereField("uid", isEqualTo: uid).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting user with uid \(uid): \(err)")
                    reject(err)
                } else {
                    do {
                        print("fetched user \(uid)")
                        let user = (try querySnapshot?.documents[0].data(as: User.self))!
                        user.id = querySnapshot?.documents[0].documentID
                        fulfill(user)
                    } catch let error {
                        print("Error decoding user")
                        reject(error)
                    }
                }
            }
        }
    }
    
    func getUser(withID id: String) -> Promise<User> {
        return Promise { fulfill, reject in
            self.usersRef?.document(id).getDocument { (document, err) in
                if let err = err {
                    print("Error getting user with id \(id): \(err)")
                    reject(err)
                } else {
                    
                    do {
                        let user = (try document!.data(as: User.self))!
                        user.id = id
                        fulfill(user)
                        print("fetched user \(id)")
                    } catch let error {
                        print("Error decoding user")
                        reject(error)
                    }
                }
            }
        }
    }
    
    func getUserReference(uid: String) -> Promise<DocumentReference> {
        // TODO: user with uid not found
        return Promise { fulfill, reject in
            self.usersRef?.whereField("uid", isEqualTo: uid).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting user with uid \(uid): \(err)")
                    reject(err)
                } else {
                    fulfill((querySnapshot?.documents[0].reference)!)
                }
            }
        }
    }
    
    func getCurrentUser() -> User {
        return self.currentUser!
    }
    
    func newConversation(name: String, listingID: String, userID: String, hostID: String) -> DocumentReference {
        let document = self.conversationsRef?.addDocument(data: [
            "name": name,
            "listingID": listingID,
            "userID": userID,
            "hostID": hostID
        ])
        return document!
    }
    
    func getConversation(listingID: String, userID: String, hostID: String, name: String) -> Promise<Conversation> {
        return Promise { fulfill, reject in
            self.conversationsRef?
            .whereField("listingID", isEqualTo: listingID)
            .whereField("userID", isEqualTo: userID)
            .getDocuments { (querySnapshot, err) in
                if querySnapshot?.documents.count == 0 {
                    print("There is no such conversation. Creating new one now")
                    let new = self.newConversation(name: name, listingID: listingID, userID: userID, hostID: hostID)
                    fulfill(Conversation(id: new.documentID, name: name, listingID: listingID, userID: userID, hostID: hostID))
                } else {
                    let snapshot = querySnapshot?.documents[0]
                    let id = snapshot!.documentID
                    let name = snapshot!["name"] as! String
                    let listingID = snapshot!["listingID"] as! String
                    let userID = snapshot!["userID"] as! String
                    fulfill(Conversation(id: id, name: name, listingID: listingID, userID: userID, hostID: hostID))
                }
            }
        }
    }
    
    func getConversations(userID: String) -> Promise<[Conversation]> {
        var conversations = [Conversation]()
        return Promise { fulfill, reject in
            self.conversationsRef?
            .whereField("hostID", isEqualTo: userID)
            .getDocuments { (querySnapshot, err) in
                
                querySnapshot?.documents.forEach({ snapshot in
                    let id = snapshot.documentID
                    let name = snapshot["name"] as! String
                    let listingID = snapshot["listingID"] as! String
                    let userID = snapshot["userID"] as! String
                    let hostID = snapshot["hostID"] as! String
                    
                    let conversation = Conversation(id: id, name: name, listingID: listingID, userID: userID, hostID: hostID)
                    conversations.append(conversation)
                })
            
                fulfill(conversations)
            }
        }
    }
    
    func addActivity(requestUser: User, quantity: Int, listing: Listing) {
        activitiesRef!.addDocument(data: [
            "hostUser": (listing.host?.id)!,
            "requestUser": (requestUser.id)!,
            "quantity": quantity,
            "listing": (listing.id)!
        ])
    }
    
    func acceptActivity(activity: Activity, accepted: Bool) {
        if (accepted) {
            activitiesRef!.document(activity.id).updateData([
                "accepted": true,
                "acceptedOn": Date()
            ]);
            
            listingsRef!.document((activity.listing?.id)!).updateData([
                "remaining": (activity.listing?.remaining)! - activity.quantity
            ])
        } else {
            activitiesRef!.document(activity.id).updateData([
                "accepted": false
            ]);
        }
        
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void){
        authController.signIn(withEmail: email, password: password) { (authResult, error) in
            guard authResult != nil else {
                completion(false)
                return
            }
            print("Login successfully")
            self.setUpListingListener()
            self.setUpUsers()
            self.setUpConversations()
            completion(true)
        }
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == ListenerType.listings ||
            listener.listenerType == ListenerType.all {
            listener.onListingsChange(change: .update, listings: listings)
        }
        
        if listener.listenerType == ListenerType.activities ||
            listener.listenerType == ListenerType.all {
            listener.onActivitiesChange(change: .update, activities: activities)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
}
