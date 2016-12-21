//
//  FriendsView.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2016-12-21.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import UIKit
import FirebaseAuth

class FriendsView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!

    var notAddedFriendLabel: UILabel!
    var sendAddRequestButton: UIButton!
    
    var stickers: [String] = []
    
    var conversationParticipants: [NSUUID]!
    
    var friends: [String]!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func initialize(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerNib(UINib(nibName: "StickerCell", bundle: nil), forCellWithReuseIdentifier: "StickerCell")
        collectionView.delaysContentTouches = false
        
        checkFriendsStatus()
    }
    
    private func checkFriendsStatus(){
        print(conversationParticipants)
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        DoodlecropUser.checkFriends(uid, participantUids: conversationParticipants, completion: { friends in
            self.friends = friends
            if friends.count == self.conversationParticipants.count {   //user is friends with everyone in the conversation
                
            } else if self.conversationParticipants.count == 1 {    // user is not friends with 1-to-1 conversation
                self.displaySendRequestButton()
            } else {    //user is not friends with everyone in a group conversation
                
            }
        })
    }
    
    private func displaySendRequestButton(){
        notAddedFriendLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 195, height: 60))
        notAddedFriendLabel.text = "You have not added this person!"
        notAddedFriendLabel.numberOfLines = 2
        notAddedFriendLabel.textColor = UIColor.darkGrayColor()
        notAddedFriendLabel.textAlignment = NSTextAlignment.Center
        notAddedFriendLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        notAddedFriendLabel.center = self.center
        notAddedFriendLabel.center.y -= 30
        self.collectionView.addSubview(notAddedFriendLabel)
        
        sendAddRequestButton = RoundedButton(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        sendAddRequestButton.backgroundColor = PINK_COLOR
        sendAddRequestButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        sendAddRequestButton.setTitle("SEND REQUEST", forState: .Normal)
        sendAddRequestButton.center = self.center
        sendAddRequestButton.center.y += 30
        sendAddRequestButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 13)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onSendRequestButtonTapped(_:)))
        sendAddRequestButton.addGestureRecognizer(tapGestureRecognizer)
        self.collectionView.addSubview(sendAddRequestButton)
    }
    
    func onSendRequestButtonTapped(sender: UITapGestureRecognizer){
        print("yo")
        sender.view?.bounce(1.15)
    }
    
    
    class func instanceFromNib(frame: CGRect) -> FriendsView {
        let view = UINib(nibName: "FriendsView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! FriendsView
        view.frame = frame

        return view
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("StickerCell", forIndexPath: indexPath) as! StickerCell
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((self.frame.width) / CGFloat(3.0) - CGFloat(15.0), (self.frame.width) / CGFloat(3.0) - CGFloat(15.0))
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

}
