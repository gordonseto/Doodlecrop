//
//  FriendsVC.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2016-12-21.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import UIKit

protocol FriendsVCDelegate {
    func friendsVCSendRequestTapped()
}

class FriendsVC: UIViewController {
    
    var friendsView: FriendsView!
    
    var delegate: FriendsVCDelegate!
    
    var conversationParticipants: [NSUUID]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        friendsView = FriendsView.instanceFromNib(CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - MESSAGE_INPUT_HEIGHT))
        friendsView.conversationParticipants = self.conversationParticipants
        friendsView.initialize()
        friendsView.delegate = self.delegate
        self.view.addSubview(friendsView)
    }

}
