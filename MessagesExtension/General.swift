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
    
    func bounce(_ amount: CGFloat) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [], animations: {
            self.transform = CGAffineTransform(scaleX: amount, y: amount)
            }, completion: {completed in
                UIView.animate(withDuration: 0.1, delay: 0.0, options: [], animations: {
                    self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    }, completion: {completed in })
        })
    }
    
    func displayBackgroundMessage(_ message: String, label: UILabel) {
        label.center = self.center
        label.text = message
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue", size: 15)
        label.textColor = UIColor.lightGray
        self.addSubview(label)
    }

}

func delay(_ amount: Double, completion: @escaping ()->()) {
    let delay = amount * Double(NSEC_PER_SEC)
    let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: time) {
        completion()
    }
}

extension MSSticker {
    func stickerFileName() -> String {
        let fullFileName = self.imageFileURL.lastPathComponent
        let fileName = String(fullFileName.characters.dropLast(4))
        return fileName
    }
}

func imageFromURL(_ url: URL) -> UIImage? {
    if let imageData = try? Data(contentsOf: url) {
        let image = UIImage(data: imageData)
        return image
    } else {
        return nil
    }
}

