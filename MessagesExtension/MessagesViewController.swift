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

class MessagesViewController: MSMessagesAppViewController, MessageVCDelegate, UIPageViewControllerDataSource, NewStickerVCDelegate {
    
    @IBOutlet weak var doodleButton: UIButton!
    @IBOutlet weak var myStickersButton: UIButton!
    @IBOutlet weak var sideBar: UIView!
    
    var cameraVC: CameraVC!
    var imagePickerVC: ImagePickerVC!
    
    var alertController: UIAlertController!
    
    var pageViewController: UIPageViewController!
    var newStickerVC: NewStickerVC!
    var myStickersVC: MyStickersVC!
    
    var conversation: MSConversation!
    var stickerView: MSStickerView!
    var sticker: MSSticker!
    
    var myStickersView: MyStickersView!
    
    var newSticker = false
    
    var imageMode: ImageMode = ImageMode.CameraVC
    
    override func willBecomeActiveWithConversation(conversation: MSConversation) {
        super.willBecomeActiveWithConversation(conversation)

        firebaseSignIn()
        self.conversation = conversation
        
        self.view.addSubview(generatePageViewController().view)
    }
    
    private func generatePageViewController() -> UIPageViewController {
        let viewController = generateNewStickerVC()
        
        pageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Vertical, options: nil)
        pageViewController.setViewControllers([viewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        pageViewController.dataSource = self
        return pageViewController
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let viewController = generateMyStickersVC()
        return viewController
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return nil
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
            doodleButton?.hidden = true
            myStickersButton?.hidden = true
            sideBar?.hidden = true
            self.stickerView?.removeFromSuperview()
        } else {
            doodleButton?.hidden = false
            myStickersButton?.hidden = false
            sideBar?.hidden = false
            if newSticker {
                //presentMyStickersView()
                newSticker = false
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
    
    @IBAction func onMyStickersButtonPressed(sender: AnyObject) {
        presentMyStickersView()
    }
    
    private func presentMyStickersView() {
        myStickersView?.removeFromSuperview()
        myStickersView = MyStickersView.instanceFromNib(CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - MESSAGE_INPUT_HEIGHT))
        myStickersView.newSticker = newSticker
        myStickersView.initialize()
        self.view.addSubview(myStickersView)
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
