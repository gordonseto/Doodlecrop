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

enum ImageMode {
    case CameraVC
    case ImagePickerVC
}

protocol MessageVCDelegate {
    func finishedCreatingMessage()
    func compactView()
    func doneSticker(sticker: MSSticker)
}

class MessagesViewController: MSMessagesAppViewController, MessageVCDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate, NewStickerVCDelegate, MyStickersVCDelegate {
    
    var cameraVC: CameraVC!
    var imagePickerVC: ImagePickerVC!
    
    var alertController: UIAlertController!
    
    var pageViewController: UIPageViewController!
    var newStickerVC: NewStickerVC!
    var myStickersVC: MyStickersVC!
    
    var conversation: MSConversation!
    
    var newSticker: Bool = false
    
    var imageMode: ImageMode = ImageMode.CameraVC
    
    override func willBecomeActiveWithConversation(conversation: MSConversation) {
        super.willBecomeActiveWithConversation(conversation)

        firebaseSignIn()
        self.conversation = conversation
        
        newStickerVC = generateNewStickerVC()
        myStickersVC = generateMyStickersVC()
        
        self.view.addSubview(generatePageViewController().view)
    }
    
    private func generatePageViewController() -> UIPageViewController {
        pageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Vertical, options: nil)
        pageViewController.setViewControllers([newStickerVC], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
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
        myStickersVC.newSticker = self.newSticker
        myStickersVC.delegate = self
        return myStickersVC
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
            self.removeChildViewControllersFrom(self)
        }
    }
    
    override func didTransitionToPresentationStyle(presentationStyle: MSMessagesAppPresentationStyle) {
        if presentationStyle == MSMessagesAppPresentationStyle.Expanded {
            self.newStickerVC?.doodleButton.hidden = true
        } else {
            self.newStickerVC?.doodleButton.hidden = false
            if newSticker {
                newSticker = false
            }
        }
    }
    
    func myStickersVCHomeButtonPressed() {
        if let newStickerVC = newStickerVC {
            pageViewController.setViewControllers([newStickerVC], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true){ completed in
            }
        }
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
