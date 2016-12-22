//
//  AddFriendView.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2016-12-21.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import UIKit
import Messages
import FirebaseAuth

class AddFriendView: UIView {

    var message: MSMessage!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

    class func instanceFromNib(frame: CGRect) -> AddFriendView {
        let view = UINib(nibName: "AddFriendView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! AddFriendView
        view.frame = frame
        
        return view
    }
    
    func initializeWith(message: MSMessage){
        self.message = message
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        guard let url = message.URL else { return }
        let userUid = String(url.absoluteString!.characters.dropFirst(1))
        DoodlecropUser.add(uid, userToAdd: userUid){ successful in
            if successful {
                
            }
        }
    }
    
}
