//
//  NewStickerVC.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2016-12-01.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import UIKit

protocol NewStickerVCDelegate {
    func newStickerCreationMethodSelected(_ imageMode: ImageMode)
}

class NewStickerVC: UIViewController {

    @IBOutlet weak var doodleButton: UIButton!
    
    var alertController: UIAlertController!
    
    var delegate: NewStickerVCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    class func instanceFromNib(_ frame: CGRect) -> NewStickerVC {
        let newStickerVC = NewStickerVC()
        let newStickerView = UINib(nibName: "NewStickerVC", bundle: nil).instantiate(withOwner: newStickerVC, options: nil)[0] as! UIView
        newStickerVC.view = newStickerView
        newStickerVC.view.frame = frame
        
        return newStickerVC
    }

    @IBAction func onDoodleButtonPressed(_ sender: AnyObject) {
        self.present(createAlertController(), animated: true){
            self.alertController?.view.superview?.subviews[1].isUserInteractionEnabled = true
            self.alertController?.view.superview?.subviews[1].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }
    
    @IBAction func onDoodleButtonTouchDown(_ sender: AnyObject) {
        doodleButton?.bounce(1.15)
    }
    
    fileprivate func createAlertController() -> UIAlertController {
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad { //user is on iPad
            alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        } else {
            alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        }
        let cameraVCAction = UIAlertAction(title: "Camera", style: .default) { (UIAlertAction) in
            self.delegate?.newStickerCreationMethodSelected(ImageMode.cameraVC)
        }
        let imagePickerVCAction = UIAlertAction(title: "Photo Library", style: .default) { (UIAlertAction) in
            self.delegate?.newStickerCreationMethodSelected(ImageMode.imagePickerVC)
        }
        alertController.addAction(imagePickerVCAction)
        alertController.addAction(cameraVCAction)
        alertController.view.transform = CGAffineTransform(translationX: 0, y: -40)
        return alertController
    }
    
    @objc fileprivate func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
}
