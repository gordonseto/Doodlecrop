//
//  MyStickersView.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2016-11-30.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import UIKit

class MyStickersView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var homeButton: UIButton!
    
    var noStickersLabel: UILabel!
    
    var stickerHistory: [String] = []
    
    var delegate: MyStickersVCDelegate!
    
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
        
        if stickerHistory.count == 0 {
            delay(0.01){
                self.showNoStickersBackgroundMessage()
            }
        } else {
            noStickersLabel?.removeFromSuperview()
        }
    }
    
    class func instanceFromNib(frame: CGRect) -> MyStickersView {
        let view = UINib(nibName: "MyStickersView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MyStickersView
        view.frame = frame
        
        return view
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("StickerCell", forIndexPath: indexPath) as! StickerCell
        //print(stickerHistory[indexPath.row])
        
        cell.configureCell(stickerHistory[indexPath.row])
        
        if newSticker {
            if indexPath.row == 0 {
                delay(0.3){
                    cell.stickerView?.bounce(1.15)
                }
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((self.frame.width) / CGFloat(3.0) - CGFloat(15.0), (self.frame.width) / CGFloat(3.0) - CGFloat(15.0))
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
    
    private func showNoStickersBackgroundMessage(){
        noStickersLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200.0, height: 100))
        noStickersLabel.numberOfLines = 2
        self.collectionView.displayBackgroundMessage("You have no stickers! Tap here to create one.", label: noStickersLabel)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onNewStickerButtonPressed))
        noStickersLabel.addGestureRecognizer(tapGestureRecognizer)
        noStickersLabel.userInteractionEnabled = true
    }
    
    func onNewStickerButtonPressed(sender: AnyObject){
        delegate?.myStickersNewStickerButtonPressed()
    }
    
    @IBAction func onHomeButtonPressed(sender: AnyObject) {
        homeButton?.bounce(1.5)
        delegate?.myStickersVCHomeButtonPressed()
        if stickerHistory.count > 0 {
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
        }
    }
    
}
