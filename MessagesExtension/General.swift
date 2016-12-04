//
//  General.swift
//  Doodle Crop
//
//  Created by Gordon Seto on 2016-11-18.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import Foundation
import UIKit
import Messages

extension UIView {
    
    func bounce(amount: CGFloat) {
        UIView.animateWithDuration(0.1, delay: 0.0, options: [], animations: {
            self.transform = CGAffineTransformMakeScale(amount, amount)
            }, completion: {completed in
                UIView.animateWithDuration(0.1, delay: 0.0, options: [], animations: {
                    self.transform = CGAffineTransformMakeScale(1.0, 1.0)
                    }, completion: {completed in })
        })
    }
    
    func displayBackgroundMessage(message: String, label: UILabel) {
        label.center = self.center
        label.text = message
        label.textAlignment = .Center
        label.font = UIFont(name: "HelveticaNeue", size: 15)
        label.textColor = UIColor.lightGrayColor()
        self.addSubview(label)
    }

}

func delay(amount: Double, completion: ()->()) {
    let delay = amount * Double(NSEC_PER_SEC)
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
    dispatch_after(time, dispatch_get_main_queue()) {
        completion()
    }
}

extension MSSticker {
    func stickerFileName() -> String {
        let fullFileName = self.imageFileURL.lastPathComponent
        let fileName = String(fullFileName!.characters.dropLast(4))
        return fileName
    }
}

func imageFromURL(url: NSURL) -> UIImage? {
    if let imageData = NSData(contentsOfURL: url) {
        let image = UIImage(data: imageData)
        return image
    } else {
        return nil
    }
}
