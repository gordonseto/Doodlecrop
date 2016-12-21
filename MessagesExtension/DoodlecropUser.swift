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
    
    static private func getFriendsOf(uid: String, completion: ([String])->()) {
        let firebase = FIRDatabase.database().reference()
        firebase.child(uid).child("friends").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            print(snapshot)
            var friendsUids: [String] = []
            if let friends = snapshot.value as? [String : NSTimeInterval]{
                print(friends)
            } else {
                completion(friendsUids)
            }
        })
    }
    
    static func checkFriends(uid: String, participantUids: [NSUUID], completion:([String])->()){
        self.getFriendsOf(uid, completion: { friends in
            let uids = participantUids.map {$0.UUIDString}.filter({friends.contains($0)})
            completion(uids)
        })
    }
    
}
