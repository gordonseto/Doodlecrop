//
//  MyStickersView.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2016-11-30.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import UIKit

protocol MyStickersViewDelegate {
    func dismissMyStickerView()
}

class MyStickersView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var homeButton: UIButton!
    
    var stickerHistory: [String] = []
    
    var delegate: MyStickersViewDelegate!
    
    var newSticker = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func initialize(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerNib(UINib(nibName: "StickerCell", bundle: nil), forCellWithReuseIdentifier: "StickerCell")
        
        loadStickers()
    }
    
    func loadStickers(){
        self.stickerHistory = StickerManager.sharedInstance.getStickerHistory()
        collectionView?.reloadData()
    }
    
    class func instanceFromNib(frame: CGRect) -> MyStickersView {
        let view = UINib(nibName: "MyStickersView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MyStickersView
        view.frame = frame
        
        return view
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("StickerCell", forIndexPath: indexPath) as! StickerCell
        print(stickerHistory[indexPath.row])
        
        cell.configureCell(stickerHistory[indexPath.row])
        
        if newSticker {
            if indexPath.row == 0 {
                delay(0.1){
                    cell.stickerView?.bounce(1.15)
                }
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((self.frame.width) / CGFloat(3.0) - CGFloat(10.0), (self.frame.width) / CGFloat(3.0) - CGFloat(10.0))
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
 
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickerHistory.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    @IBAction func onHomeButtonPressed(sender: AnyObject) {
        self.removeFromSuperview()
    }
    
}
