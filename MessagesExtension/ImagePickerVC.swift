//
//  ImagePickerVC.swift
//  Doodle Crop
//
//  Created by Gordon Seto on 2016-11-17.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import UIKit
import DKImagePickerController

class ImagePickerVC: DoodlecropViewController {
    
    var formattedImage: UIImage!
    
    weak var imagePickerController: DKImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presentViewController(generateImagePickerController(), animated: false, completion: nil)
    }
    
    private func generateImagePickerController() -> DKImagePickerController {
        imagePickerController = DKImagePickerController()
        imagePickerController.singleSelect = true
        imagePickerController.didSelectAssets = { (assets: [DKAsset]) in
            assets.first?.fetchFullScreenImageWithCompleteBlock({ (image, info) in
                if let image = image {
                    self.insertImage(image)
                }
            })
        }
        imagePickerController.didCancel = {
            self.delegate?.compactView()
        }
        return imagePickerController
    }

    @objc override internal func cancelImagePreview(animated: Bool = false){
        self.presentViewController(generateImagePickerController(), animated: animated){
            self.cutView?.removeFromSuperview()
            self.cancelButton?.removeFromSuperview()
            self.sendButton?.removeFromSuperview()
            self.cutImageView?.removeFromSuperview()
            self.blurEffectView?.removeFromSuperview()
            self.removeOnboard()
        }
    }
    
}
