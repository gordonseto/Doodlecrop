//
//  DoodlecropUser.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2016-12-21.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class DoodlecropUser {
    
    static func getFriendsOf(uid: String, completion: ([String])->()) {
        let firebase = FIRDatabase.database().reference()
        firebase.child("users").child(uid).child("friends").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            var friendsUids: [String] = []
            if let friends = snapshot.value as? [String : NSTimeInterval]{
                friendsUids = friends.map({$0.0})
            }
            completion(friendsUids)
        })
    }
    
    static func add(uid: String, userToAdd: String, completion:(Bool)->()){
        print(userToAdd)
        let firebase = FIRDatabase.database().reference()
        let time = NSDate().timeIntervalSince1970
        firebase.child("users").child(uid).child("friends").child(userToAdd).setValue(time)
        firebase.child("users").child(userToAdd).child("friends").child(uid).setValue(time) { (error, reference) in
            if error != nil {
                print(error)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
}
