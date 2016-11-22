//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Gordon Seto on 2016-11-21.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import UIKit
import Messages

enum ImageMode {
    case CameraVC
    case ImagePickerVC
}

protocol MessageVCDelegate {
    func finishedCreatingMessage()
    func compactView()
    func doneSticker(sticker: MSSticker)
}

class MessagesViewController: MSMessagesAppViewController, MessageVCDelegate {
    
    @IBOutlet weak var doodleButton: UIButton!
    
    var cameraVC: CameraVC!
    var imagePickerVC: ImagePickerVC!
    
    var alertController: UIAlertController!
    
    var conversation: MSConversation!
    var stickerView: MSStickerView!
    var sticker: MSSticker!
    
    var imageMode: ImageMode = ImageMode.CameraVC
    
    override func willBecomeActiveWithConversation(conversation: MSConversation) {
        super.willBecomeActiveWithConversation(conversation)
        
        self.conversation = conversation
    }
    
    override func willTransitionToPresentationStyle(presentationStyle: MSMessagesAppPresentationStyle) {
        super.willTransitionToPresentationStyle(presentationStyle)
        if presentationStyle == MSMessagesAppPresentationStyle.Expanded {
            if imageMode == .CameraVC {
                presentCameraVC()
            } else if imageMode == .ImagePickerVC {
                presentImagePickerVC()
            }
        } else {
            self.cameraVC?.dismissViewControllerAnimated(false, completion: nil)
            self.imagePickerVC?.dismissViewControllerAnimated(false, completion: nil)
            self.removeChildViewControllers()
        }
    }
    
    override func didTransitionToPresentationStyle(presentationStyle: MSMessagesAppPresentationStyle) {
        if presentationStyle == MSMessagesAppPresentationStyle.Expanded {
            doodleButton.hidden = true
            self.stickerView?.removeFromSuperview()
        } else {
            doodleButton.hidden = false
            delay(0.1){
                self.addSticker()
            }
        }
    }
    
    private func addSticker(){
        if let sticker = sticker {
            if let stickerView = stickerView {
                stickerView.sticker = sticker
                self.view.addSubview(stickerView)
            } else {
                self.stickerView = MSStickerView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), sticker: sticker)
                self.view.addSubview(stickerView)
                print("sticker path: \(sticker.imageFileURL)")
            }
            stickerView?.bounce(1.15)
        }
    }
    
    @IBAction func onDoodleButtonPressed(sender: AnyObject) {
        doodleButton.bounce(1.15)
        self.presentViewController(createAlertController(), animated: true){
            self.alertController?.view.superview?.subviews[1].userInteractionEnabled = true
            self.alertController?.view.superview?.subviews[1].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }
    
    private func createAlertController() -> UIAlertController {
        alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cameraVCAction = UIAlertAction(title: "Camera", style: .Default) { (UIAlertAction) in
            self.imageMode = ImageMode.CameraVC
            self.requestPresentationStyle(MSMessagesAppPresentationStyle.Expanded)
        }
        let imagePickerVCAction = UIAlertAction(title: "Photo Library", style: .Default) { (UIAlertAction) in
            self.imageMode = ImageMode.ImagePickerVC
            self.requestPresentationStyle(MSMessagesAppPresentationStyle.Expanded)
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
    
    @IBAction func onGalleryButtonPressed(sender: AnyObject) {
        imageMode = ImageMode.ImagePickerVC
        self.requestPresentationStyle(MSMessagesAppPresentationStyle.Expanded)
    }
    
    
    private func presentCameraVC(){
        cameraVC = CameraVC()
        cameraVC.delegate = self
        cameraVC.conversation = self.conversation
        cameraVC.isMessageMode = true
        initializeViewController(cameraVC)
    }
    
    private func presentImagePickerVC(){
        imagePickerVC = ImagePickerVC()
        imagePickerVC.delegate = self
        imagePickerVC.conversation = self.conversation
        initializeViewController(imagePickerVC)
    }
    
    func doneSticker(sticker: MSSticker) {
        self.sticker = sticker
        self.requestPresentationStyle(MSMessagesAppPresentationStyle.Compact)
    }
    
    func finishedCreatingMessage() {
        self.dismiss()
    }
    
    func compactView() {
        self.requestPresentationStyle(MSMessagesAppPresentationStyle.Compact)
    }
    
    private func removeChildViewControllers(){
        for child in childViewControllers {
            child.willMoveToParentViewController(nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
    }
    
    private func initializeViewController(controller: UIViewController){
        
        removeChildViewControllers()
        
        addChildViewController(controller)
        
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        controller.view.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        controller.view.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
        controller.view.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        controller.view.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        
        controller.didMoveToParentViewController(self)
    }
    
}
