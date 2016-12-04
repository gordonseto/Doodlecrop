//
//  ShareStickerView.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2016-12-03.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import UIKit
import Messages

class ShareStickerView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    class func instanceFromNib(frame: CGRect) -> ShareStickerView {
        let view = UINib(nibName: "ShareStickerView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ShareStickerView
        view.frame = frame
        
        return view
    }
    
    func initializeWith(message: MSMessage){
        guard let url = message.URL else { return }
        StickerManager.sharedInstance.downloadSticker(url) { image in
            self.imageView.image = image
        }
    }

}
