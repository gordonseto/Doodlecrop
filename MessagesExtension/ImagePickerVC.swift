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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presentViewController(generateImagePickerController(), animated: false, completion: nil)
    }
    
    private func generateImagePickerController() -> DKImagePickerController {
        let imagePickerController = DKImagePickerController()
        imagePickerController.singleSelect = true
        imagePickerController.didSelectAssets = { (assets: [DKAsset]) in
            assets.first?.fetchFullScreenImageWithCompleteBlock({ (image, info) in
                if let image = image {
                    if let formattedImage = self.formatImage(image) {
                        self.insertImage(formattedImage)
                    }
                }
            })
        }
        imagePickerController.didCancel = {
            self.delegate?.compactView()
        }
        return imagePickerController
    }
    
    private func formatImage(image: UIImage) -> UIImage! {
        let formattedImageView = UIImageView((frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)))
        formattedImageView.image = image
        formattedImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.view.addSubview(formattedImageView)
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let formattedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        formattedImageView.removeFromSuperview()
        return formattedImage
    }

    @objc override internal func cancelImagePreview(){
        self.presentViewController(generateImagePickerController(), animated: false){
            self.cutView?.removeFromSuperview()
            self.cancelButton?.removeFromSuperview()
            self.sendButton?.removeFromSuperview()
            self.cutImageView?.removeFromSuperview()
        }
    }
    
}
