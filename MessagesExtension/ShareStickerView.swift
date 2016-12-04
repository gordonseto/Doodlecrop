//
//  ShareStickerView.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2016-12-03.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import UIKit
import Messages

protocol ShareStickerViewDelegate {
    func onShareStickerViewSavePressed()
}

class ShareStickerView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    var message: MSMessage!
    
    var delegate: ShareStickerViewDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    class func instanceFromNib(frame: CGRect) -> ShareStickerView {
        let view = UINib(nibName: "ShareStickerView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ShareStickerView
        view.frame = frame
        
        return view
    }
    
    func initializeWith(message: MSMessage){
        self.message = message
        guard let fileName = message.URL else { return }
        StickerManager.sharedInstance.downloadSticker(fileName) { image in
            self.imageView.image = image
        }
    }

    @IBAction func onSaveButtonPressed(sender: AnyObject) {
        guard let image = self.imageView.image else { return }
        guard let message = self.message else { return }
        guard let fileName = message.URL else { return }
        StickerManager.sharedInstance.saveSticker(fileName.absoluteString!, image: image)
        saveButton.userInteractionEnabled = false
        saveButton.setTitle("SAVED", forState: UIControlState.Normal)
        print("saved image!")
        delay(0.3){
            self.delegate?.onShareStickerViewSavePressed()
        }
    }
    
    @IBAction func onSaveButtonTouchDown(sender: AnyObject) {
        saveButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        saveButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
    }
}
