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
    
    class func instanceFromNib(_ frame: CGRect) -> ShareStickerView {
        let view = UINib(nibName: "ShareStickerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ShareStickerView
        view.frame = frame
        
        return view
    }
    
    func initializeWith(_ message: MSMessage){
        self.message = message
        guard let fileName = message.url else { return }
        StickerManager.sharedInstance.downloadSticker(fileName) { image in
            self.imageView.image = image
        }
    }

    @IBAction func onSaveButtonPressed(_ sender: AnyObject) {
        guard let image = self.imageView.image else { return }
        guard let message = self.message else { return }
        guard let fileName = message.url else { return }
        StickerManager.sharedInstance.saveSticker(fileName.absoluteString, image: image)
        saveButton.isUserInteractionEnabled = false
        saveButton.setTitle("SAVED", for: UIControlState())
        saveButton.setTitleColor(UIColor.lightGray, for: UIControlState())
        print("saved image!")
        delay(0.3){
            self.delegate?.onShareStickerViewSavePressed()
        }
    }
    
    @IBAction func onSaveButtonTouchDown(_ sender: AnyObject) {
        saveButton.backgroundColor = UIColor.gray
    }
}
