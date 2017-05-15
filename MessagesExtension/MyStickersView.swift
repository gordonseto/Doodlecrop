//
//  MyStickersView.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2016-11-30.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import UIKit
import Messages

protocol MyStickersViewDelegate {
    func onMyStickersViewStickerTapped(_ cell: StickerCell)
}

class MyStickersView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var homeButton: UIButton!
    
    var noStickersLabel: UILabel!
    
    var stickerHistory: [String] = []
    
    var delegate: MyStickersVCDelegate!
    var controllerDelegate: MyStickersViewDelegate!
    
    var newSticker = false
    
    var selectedCell: StickerCell!
    
    var onboardView: OnboardView!
    var onboardButton: RoundedButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func initialize(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "StickerCell", bundle: nil), forCellWithReuseIdentifier: "StickerCell")
        
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
            if UserDefaults.standard.object(forKey: "HAS_ONBOARDED_STICKER") == nil {
                delay(0.5){
                    self.showOnboard()
                }
                UserDefaults.standard.set(true, forKey: "HAS_ONBOARDED_STICKER")
            }
        }
    }
    
    class func instanceFromNib(_ frame: CGRect) -> MyStickersView {
        let view = UINib(nibName: "MyStickersView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MyStickersView
        view.frame = frame
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickerCell", for: indexPath) as! StickerCell
        
        cell.configureCell(stickerHistory[indexPath.row])
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyStickersView.onStickerViewTapped(_:)))
        cell.stickerView?.addGestureRecognizer(tapGestureRecognizer)
        unhighlightCell(cell)
        
        if newSticker {
            self.newSticker = false
            if indexPath.row == 0 {
                delay(0.3){
                    cell.stickerView?.bounce(1.15)
                }
            }
        }
        return cell
    }
    
    func onStickerViewTapped(_ gestureRecognizer: UIGestureRecognizer){
        unhighlightCell(selectedCell)
        if let stickerView = gestureRecognizer.view as? MSStickerView {
            if let sticker = stickerView.sticker {
                guard let fileName = sticker.imageFileURL.lastPathComponent.characters.dropLast(4) else { return }
                print(fileName)
                guard let index = stickerHistory.index(of: String(fileName)) else { return }
                let indexPath = IndexPath(item: index, section: 0)
                guard let cell = collectionView.cellForItem(at: indexPath) as? StickerCell else { return }
                highlightCell(cell)
                self.selectedCell = cell
                controllerDelegate?.onMyStickersViewStickerTapped(cell)
            }
        }
    }
    
    func highlightCell(_ cell: StickerCell?){
        cell?.bounce(1.15)
        cell?.layer.borderWidth = 5.0
        cell?.layer.borderColor = PINK_COLOR.cgColor
        cell?.layer.cornerRadius = 5.0
    }
    
    func unhighlightCell(_ cell: StickerCell?){
        cell?.layer.borderWidth = 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.frame.width) / CGFloat(3.0) - CGFloat(15.0), height: (self.frame.width) / CGFloat(3.0) - CGFloat(15.0))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickerHistory.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    fileprivate func showOnboard(){
        onboardView?.removeFromSuperview()
        
        onboardView = OnboardView(frame: self.frame)
        self.addSubview(onboardView)
        onboardView.showOnboard(self.frame, message: "Hold down on your sticker to paste it in the conversation")
    }
    
    fileprivate func showNoStickersBackgroundMessage(){
        noStickersLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200.0, height: 100))
        noStickersLabel.numberOfLines = 2
        self.collectionView.displayBackgroundMessage("You have no stickers! Tap here to create one.", label: noStickersLabel)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onNewStickerButtonPressed))
        noStickersLabel.addGestureRecognizer(tapGestureRecognizer)
        noStickersLabel.isUserInteractionEnabled = true
    }
    
    func onNewStickerButtonPressed(_ sender: AnyObject){
        delegate?.myStickersNewStickerButtonPressed()
    }
    
    @IBAction func onHomeButtonPressed(_ sender: AnyObject) {
        homeButton?.bounce(1.5)
        delegate?.myStickersVCHomeButtonPressed()
        if stickerHistory.count > 0 {
            let indexPath = IndexPath(row: 0, section: 0)
            collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.top, animated: true)
        }
    }
    
}
