
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
            self.presentViewController(self.createDKCamera(), animated: false, completion: nil)
        }
    }
    
    private func createDKCamera() -> DKCamera {
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
    
    private func imageCaptured(camera: DKCamera, image: UIImage){
        print("didFinishCapturingImage")
        print(image)
        self.capturedImage = image
        if let _ = self.capturedImage {
            if camera.currentDevice == camera.captureDeviceFront {
                isFront = true
                let flippedImage = UIImage(CGImage: image.CGImage!, scale: 1.0, orientation: .LeftMirrored)
                self.insertImage(flippedImage)
            } else {
                isFront = false
                self.insertImage(image)
            }
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    @objc override internal func cancelImagePreview(){
        self.presentViewController(createDKCamera(), animated: false){
            self.cutView?.removeFromSuperview()
            self.cancelButton?.removeFromSuperview()
            self.sendButton?.removeFromSuperview()
            self.cutImageView?.removeFromSuperview()
        }
    }
    
}

