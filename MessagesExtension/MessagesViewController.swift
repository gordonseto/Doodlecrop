//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Gordon Seto on 2016-11-21.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import UIKit
import Messages
import Firebase
import FirebaseAuth
import Fabric
import Crashlytics

enum ImageMode {
    case CameraVC
    case ImagePickerVC
}

protocol MessageVCDelegate {
    func finishedCreatingMessage()
    func compactView()
    func doneSticker(sticker: MSSticker)
}

class MessagesViewController: MSMessagesAppViewController, MessageVCDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate, NewStickerVCDelegate, MyStickersVCDelegate, ShareStickerViewDelegate {
    
    var cameraVC: CameraVC!
    var imagePickerVC: ImagePickerVC!
    
    var alertController: UIAlertController!
    
    var pageViewController: UIPageViewController!
    var newStickerVC: NewStickerVC!
    var myStickersVC: MyStickersVC!
    
    var shareStickerView: ShareStickerView!
    
    var conversation: MSConversation!
    var selectedMessage: MSMessage!
    
    var newSticker: Bool = false
    
    var imageMode: ImageMode = ImageMode.CameraVC
    
    let myStickersVCKey = "MY_STICKERS_VC"
    let newStickerVCKey = "NEW_STICKER_VC"
    
    override func willBecomeActiveWithConversation(conversation: MSConversation) {
        super.willBecomeActiveWithConversation(conversation)

        Fabric.with([Crashlytics.self])
        
        firebaseSignIn()
        self.conversation = conversation
        
        newStickerVC = generateNewStickerVC()
        myStickersVC = generateMyStickersVC()
        pageViewController = generatePageViewController()
        
        selectedMessage = conversation.selectedMessage
        
        if let _ = self.selectedMessage { //this is a share sticker menu
            self.view.addSubview(generateShareStickerView())
        } else {    // this is the regular app
            self.view.addSubview(pageViewController.view)
        }
        
        if let versionNumber = NSUserDefaults.standardUserDefaults().objectForKey("VERSION_NUMBER") {
            print(versionNumber)
        } else {
            NSUserDefaults.standardUserDefaults().setObject(VERSION_NUMBER, forKey: "VERSION_NUMBER")
        }
    }
    
    private func generatePageViewController() -> UIPageViewController {
        pageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Vertical, options: nil)
        
        pageViewController.setViewControllers([newStickerVC], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        if let lastViewController = NSUserDefaults.standardUserDefaults().objectForKey("LAST_VIEW_CONTROLLER") {
            if lastViewController as! String == myStickersVCKey {
                pageViewController.setViewControllers([myStickersVC], direction: UIPageViewControllerNavigationDirection.Reverse, animated: false, completion: nil)
            }
        }
        pageViewController.dataSource = self
        pageViewController.delegate = self
        return pageViewController
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let controller = pageViewController.viewControllers?.last
        
        if controller is NewStickerVC {
            return myStickersVC
        } else {
            return nil
        }
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let controller = pageViewController.viewControllers?.last
        
        if controller is MyStickersVC {
            return newStickerVC
        } else {
            return nil
        }
    }
    
    override func willResignActiveWithConversation(conversation: MSConversation) {
        let controller = pageViewController?.viewControllers?.last
        
        if controller is MyStickersVC {
            NSUserDefaults.standardUserDefaults().setObject(myStickersVCKey, forKey: "LAST_VIEW_CONTROLLER")
        } else {
            NSUserDefaults.standardUserDefaults().setObject(newStickerVCKey, forKey: "LAST_VIEW_CONTROLLER")
        }
    }

    private func generateNewStickerVC() -> NewStickerVC {
        newStickerVC = NewStickerVC.instanceFromNib(self.view.frame)
        newStickerVC.delegate = self
        return newStickerVC
    }
    
    func newStickerCreationMethodSelected(imageMode: ImageMode) {
        self.imageMode = imageMode
        self.requestPresentationStyle(MSMessagesAppPresentationStyle.Expanded)
    }
    
    private func generateMyStickersVC() -> MyStickersVC {
        myStickersVC = MyStickersVC()
        myStickersVC.delegate = self
        return myStickersVC
    }
    
    override func willTransitionToPresentationStyle(presentationStyle: MSMessagesAppPresentationStyle) {
        super.willTransitionToPresentationStyle(presentationStyle)
        if presentationStyle == MSMessagesAppPresentationStyle.Expanded {
            if self.selectedMessage == nil {
                if imageMode == .CameraVC {
                    presentCameraVC()
                } else if imageMode == .ImagePickerVC {
                    presentImagePickerVC()
                }
            }
        } else {
            self.selectedMessage = nil
            self.cameraVC?.dismissViewControllerAnimated(false, completion: nil)
            self.imagePickerVC?.dismissViewControllerAnimated(false, completion: nil)
            self.removeChildViewControllersFrom(self)
        }
    }
    
    override func didTransitionToPresentationStyle(presentationStyle: MSMessagesAppPresentationStyle) {
        if presentationStyle == MSMessagesAppPresentationStyle.Expanded {
            self.newStickerVC?.doodleButton.hidden = true
            self.pageViewController?.view?.removeFromSuperview()
            
            if self.selectedMessage != nil {
                self.view.addSubview(generateShareStickerView())
            }
            
        } else {
            self.newStickerVC?.doodleButton.hidden = false
            self.shareStickerView?.removeFromSuperview()
            pageViewController?.view.frame = self.view.frame
            self.view.addSubview(pageViewController.view)
            if newSticker {
                delay(0.01){
                    self.scrollToMyStickersVC(true)
                    self.newSticker = false
                }
            }
        }
    }
    
    override func didSelectMessage(message: MSMessage, conversation: MSConversation) {
        print("did Select Message")
        self.selectedMessage = conversation.selectedMessage
    }
    
    private func scrollToMyStickersVC(animated: Bool){
        if let myStickersVC = myStickersVC {
            pageViewController.setViewControllers([myStickersVC], direction: UIPageViewControllerNavigationDirection.Forward, animated: animated, completion: nil)
            myStickersVC.reloadStickers()
        }
    }
    
    func myStickersVCHomeButtonPressed() {
        if let newStickerVC = newStickerVC {
            pageViewController.setViewControllers([newStickerVC], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true, completion: nil)
        }
    }
    
    func myStickersNewStickerButtonPressed() {
        if let newStickerVC = newStickerVC {
            pageViewController.setViewControllers([newStickerVC], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true) { completed in
                newStickerVC.doodleButton?.bounce(1.15)
                newStickerVC.onDoodleButtonPressed(UIView())
            }
        }
    }
    
    func myStickersVCSendSticker(sticker: MSSticker) {
        self.conversation.insertSticker(sticker) { (error) in
            if error != nil {
                print(error)
            }
        }
    }
    
    func myStickersVCShareSticker(sticker: MSSticker) {
        StickerManager.sharedInstance.checkIfStickerExists(sticker, completion: { (exists) in
            if exists {
                self.myStickersVC?.removeLoadingView()
                self.insertStickerIntoMessage(sticker)
            } else {
                StickerManager.sharedInstance.uploadSticker(sticker, completion: { _ in
                    self.myStickersVC?.removeLoadingView()
                    self.insertStickerIntoMessage(sticker)
                })
            }
        })
    }
    
    private func insertStickerIntoMessage(sticker: MSSticker){
        guard let image = imageFromURL(sticker.imageFileURL) else { return }
        let layout = MSMessageTemplateLayout()
        layout.image = image
        layout.caption = "Tap to save this Doodlecrop!"
        
        let message = MSMessage()
        message.layout = layout
        message.URL = NSURLComponents(string: sticker.stickerFileName())!.URL
        
        self.conversation?.insertMessage(message, completionHandler: { (error) in
            if error != nil {
                print(error)
            }
        })
    }
    
    func onShareStickerViewSavePressed() {
        scrollToMyStickersVC(false)
        self.requestPresentationStyle(MSMessagesAppPresentationStyle.Compact)
    }
    
    func generateShareStickerView() -> ShareStickerView {
        shareStickerView = ShareStickerView.instanceFromNib(self.view.frame)
        shareStickerView.delegate = self
        shareStickerView.initializeWith(conversation.selectedMessage!)
        return shareStickerView
    }
    
    private func presentCameraVC(){
        cameraVC = CameraVC()
        cameraVC.delegate = self
        cameraVC.conversation = self.conversation
        cameraVC.isMessageMode = true
        initializeViewController(self, controller: cameraVC)
    }
    
    private func presentImagePickerVC(){
        imagePickerVC = ImagePickerVC()
        imagePickerVC.delegate = self
        imagePickerVC.conversation = self.conversation
        initializeViewController(self, controller: imagePickerVC)
    }
    
    func doneSticker(sticker: MSSticker) {
        self.newSticker = true
        self.requestPresentationStyle(MSMessagesAppPresentationStyle.Compact)
    }
    
    func finishedCreatingMessage() {
        self.dismiss()
    }
    
    func compactView() {
        self.requestPresentationStyle(MSMessagesAppPresentationStyle.Compact)
    }
    
    private func removeChildViewControllersFrom(parent: UIViewController){
        for child in parent.childViewControllers {
            child.willMoveToParentViewController(nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
    }
    
    private func initializeViewController(parent: UIViewController, controller: UIViewController){
        
        removeChildViewControllersFrom(parent)

        parent.addChildViewController(controller)
        
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        parent.view.addSubview(controller.view)
        
        controller.view.leftAnchor.constraintEqualToAnchor(parent.view.leftAnchor).active = true
        controller.view.rightAnchor.constraintEqualToAnchor(parent.view.rightAnchor).active = true
        controller.view.topAnchor.constraintEqualToAnchor(parent.view.topAnchor).active = true
        controller.view.bottomAnchor.constraintEqualToAnchor(parent.view.bottomAnchor).active = true
        
        controller.didMoveToParentViewController(self)
    }
    
    private func firebaseSignIn(){
        if FIRAuth.auth()?.currentUser == nil {
            FIRApp.configure()
            FIRAuth.auth()?.signInAnonymouslyWithCompletion({ (user, error) in
                if error != nil {
                    print(error)
                } else {
                    print(user?.uid)
                }
            })
        }
    }
    
}
