//
//  NewStickerVC.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2016-12-01.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import UIKit

protocol NewStickerVCDelegate {
    func newStickerCreationMethodSelected(imageMode: ImageMode)
}

class NewStickerVC: UIViewController {

    @IBOutlet weak var doodleButton: UIButton!
    
    var alertController: UIAlertController!
    
    var delegate: NewStickerVCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    class func instanceFromNib(frame: CGRect) -> NewStickerVC {
        let newStickerVC = NewStickerVC()
        let newStickerView = UINib(nibName: "NewStickerVC", bundle: nil).instantiateWithOwner(newStickerVC, options: nil)[0] as! UIView
        newStickerVC.view = newStickerView
        newStickerVC.view.frame = frame
        
        return newStickerVC
    }

    @IBAction func onDoodleButtonPressed(sender: AnyObject) {
        doodleButton?.bounce(1.15)
        self.presentViewController(createAlertController(), animated: true){
            self.alertController?.view.superview?.subviews[1].userInteractionEnabled = true
            self.alertController?.view.superview?.subviews[1].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }
    
    private func createAlertController() -> UIAlertController {
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad { //user is on iPad
            alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        } else {
            alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        }
        let cameraVCAction = UIAlertAction(title: "Camera", style: .Default) { (UIAlertAction) in
            self.delegate?.newStickerCreationMethodSelected(ImageMode.CameraVC)
        }
        let imagePickerVCAction = UIAlertAction(title: "Photo Library", style: .Default) { (UIAlertAction) in
            self.delegate?.newStickerCreationMethodSelected(ImageMode.ImagePickerVC)
        }
        alertController.addAction(imagePickerVCAction)
        alertController.addAction(cameraVCAction)
        alertController.view.transform = CGAffineTransformMakeTranslation(0, -40)
        return alertController
    }
    
    @objc private func alertControllerBackgroundTapped()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
