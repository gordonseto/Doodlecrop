
//
//  ViewController.swift
//  Image Cropper
//
//  Created by Gordon Seto on 2016-10-27.
//  Copyright © 2016 gordonseto. All rights reserved.
//
import UIKit
import DKCamera
import ImageFreeCut
import Messages
import MessageUI

class CameraVC: DoodlecropViewController {
    
    var capturedImage: UIImage!
    
    var isFront: Bool = false
    
    var isMessageMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delay(0.05) {
            self.present(self.createDKCamera(), animated: false, completion: nil)
        }
    }
    
    fileprivate func createDKCamera() -> DKCamera {
        let camera = DKCamera()
        camera.isMessageMode = self.isMessageMode
        
        camera.didCancel = { () in
            print("didCancel")
            self.delegate?.compactView()
        }
        
        camera.didFinishCapturingImage = {(image: UIImage) in
            self.imageCaptured(camera, image: image)
        }
        
        return camera
    }
    
    fileprivate func imageCaptured(_ camera: DKCamera, image: UIImage){
        print("didFinishCapturingImage")
        print(image)
        self.capturedImage = image
        if let _ = self.capturedImage {
            if camera.currentDevice == camera.captureDeviceFront {
                isFront = true
                let flippedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .leftMirrored)
                self.insertImage(formatImage(flippedImage))
            } else {
                isFront = false
                self.insertImage(formatImage(image))
            }
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    fileprivate func formatImage(_ image: UIImage) -> UIImage! {
        let formattedImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        formattedImageView.image = image
        self.view.addSubview(formattedImageView)
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let formattedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        formattedImageView.removeFromSuperview()
        return formattedImage
    }
    
    @objc override internal func cancelImagePreview(_ animated: Bool = false){
        self.present(createDKCamera(), animated: animated){
            self.cutView?.removeFromSuperview()
            self.cancelButton?.removeFromSuperview()
            self.sendButton?.removeFromSuperview()
            self.cutImageView?.removeFromSuperview()
            self.blurEffectView?.removeFromSuperview()
            self.removeOnboard()
        }
    }
    
}

