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
    var usersRef: CollectionReference?
    var listings: [Listing]
    
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        listings = [Listing]()
        
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
    }

    
    // MARK:- Parse Functions for Firebase Firestore responses
    func parseListingsSnapshot(snapshot: QuerySnapshot) {

        snapshot.documentChanges.forEach { (change) in
            let listingID = change.document.documentID
            
            var parsedListing: Listing?
            
            do {
                parsedListing = try change.document.data(as: Listing.self)
            } catch {
                print("Unable to decode listing.")
                return
            }
            
            guard let listing = parsedListing else {
                print("Document doesn't exist")
                return;
            }
            
            listing.id = listingID
            if change.type == .added {
                listings.append(listing)
            }
            else if change.type == .modified {
                let index = getListingIndexByID(listingID)!
                listings[index] = listing
            }
            else if change.type == .removed {
                if let index = getListingIndexByID(listingID) {
                    listings.remove(at: index)
                }
            }
        }
        
        print("parse successfully")
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.listings ||
                listener.listenerType == ListenerType.all {
                print("invoking", listener)
                listener.onListingsChange(change: .update, listings: listings)
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
    
    func getUser(uid: String) -> Promise<User> {
        // TODO: user with uid not found
        return Promise { fulfill, reject in
            self.usersRef?.whereField("uid", isEqualTo: uid).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting user with uid \(uid): \(err)")
                    reject(err)
                } else {
                    do {
                        print("fetched user \(uid)")
                        fulfill((try querySnapshot?.documents[0].data(as: User.self))!)
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
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void){
        authController.signIn(withEmail: email, password: password) { (authResult, error) in
            guard authResult != nil else {
                completion(false)
                return
            }
            print("Login successfully")
            self.setUpListingListener()
            self.setUpUsers()
            completion(true)
        }
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == ListenerType.listings ||
            listener.listenerType == ListenerType.all {
            listener.onListingsChange(change: .update, listings: listings)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
}
