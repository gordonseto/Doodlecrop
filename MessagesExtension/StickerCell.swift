//
//  StickerCell.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2016-11-30.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import UIKit
import Messages

class StickerCell: UICollectionViewCell {

    var stickerView: MSStickerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureCell(fileName: String){
        let sticker = StickerManager.sharedInstance.loadSticker(fileName)
        stickerView = MSStickerView(frame: self.frame, sticker: sticker)
        self.addSubview(stickerView)
        stickerView.backgroundColor = UIColor.redColor()
    }

}
