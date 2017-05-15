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
    case cameraVC
    case imagePickerVC
}

protocol MessageVCDelegate: class {
    func finishedCreatingMessage()
    func compactView()
    func doneSticker(_ sticker: MSSticker)
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
    
    var imageMode: ImageMode = ImageMode.cameraVC
    
    let myStickersVCKey = "MY_STICKERS_VC"
    let newStickerVCKey = "NEW_STICKER_VC"
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)

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
        
        if let versionNumber = UserDefaults.standard.object(forKey: "VERSION_NUMBER") {
            print(versionNumber)
        } else {
            UserDefaults.standard.set(VERSION_NUMBER, forKey: "VERSION_NUMBER")
        }
    }
    
    fileprivate func generatePageViewController() -> UIPageViewController {
        pageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.vertical, options: nil)

        pageViewController.safeSetViewController(newStickerVC, direction: .forward, animated: false, completion: nil)
        if let lastViewController = UserDefaults.standard.object(forKey: "LAST_VIEW_CONTROLLER") {
            if lastViewController as! String == myStickersVCKey {
                pageViewController.safeSetViewController(myStickersVC, direction: .reverse, animated: false, completion: nil)
            }
        }
        pageViewController.dataSource = self
        pageViewController.delegate = self
        return pageViewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let controller = pageViewController.viewControllers?.last
        
        if controller is NewStickerVC {
            return myStickersVC
        } else {
            return nil
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let controller = pageViewController.viewControllers?.last
        
        if controller is MyStickersVC {
            return newStickerVC
        } else {
            return nil
        }
    }
    
    override func willResignActive(with conversation: MSConversation) {
        let controller = pageViewController?.viewControllers?.last
        
        if controller is MyStickersVC {
            UserDefaults.standard.set(myStickersVCKey, forKey: "LAST_VIEW_CONTROLLER")
        } else {
            UserDefaults.standard.set(newStickerVCKey, forKey: "LAST_VIEW_CONTROLLER")
        }
    }

    fileprivate func generateNewStickerVC() -> NewStickerVC {
        newStickerVC = NewStickerVC.instanceFromNib(self.view.frame)
        newStickerVC.delegate = self
        return newStickerVC
    }
    
    func newStickerCreationMethodSelected(_ imageMode: ImageMode) {
        self.imageMode = imageMode
        self.requestPresentationStyle(MSMessagesAppPresentationStyle.expanded)
    }
    
    fileprivate func generateMyStickersVC() -> MyStickersVC {
        myStickersVC = MyStickersVC()
        myStickersVC.delegate = self
        return myStickersVC
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.willTransition(to: presentationStyle)
        if presentationStyle == MSMessagesAppPresentationStyle.expanded {
            if self.selectedMessage == nil {
                if imageMode == .cameraVC {
                    presentCameraVC()
                } else if imageMode == .imagePickerVC {
                    presentImagePickerVC()
                }
            }
        } else {
            self.selectedMessage = nil
            self.cameraVC?.dismiss(animated: false, completion: nil)
            self.imagePickerVC?.dismiss(animated: false, completion: nil)
            self.removeChildViewControllersFrom(self)
        }
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        if presentationStyle == MSMessagesAppPresentationStyle.expanded {
            self.newStickerVC?.doodleButton.isHidden = true
            self.pageViewController?.view?.removeFromSuperview()
            
            if self.selectedMessage != nil {
                self.view.addSubview(generateShareStickerView())
            }
            
        } else {
            self.newStickerVC?.doodleButton.isHidden = false
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
    
    override func didSelect(_ message: MSMessage, conversation: MSConversation) {
        print("did Select Message")
        self.selectedMessage = conversation.selectedMessage
    }
    
    fileprivate func scrollToMyStickersVC(_ animated: Bool){
        if let myStickersVC = myStickersVC {
            pageViewController.safeSetViewController(myStickersVC, direction: .forward, animated: animated, completion: nil)
            myStickersVC.reloadStickers()
        }
    }
    
    func myStickersVCHomeButtonPressed() {
        if let newStickerVC = newStickerVC {
            pageViewController.safeSetViewController(newStickerVC, direction: .reverse, animated: true, completion: nil)
        }
    }
    
    func myStickersNewStickerButtonPressed() {
        if let newStickerVC = newStickerVC {
            pageViewController.safeSetViewController(newStickerVC, direction: .reverse, animated: true, completion: { (completed) in
                newStickerVC.doodleButton?.bounce(1.15)
                newStickerVC.onDoodleButtonPressed(UIView())
            })
        }
    }
    
    func myStickersVCSendSticker(_ sticker: MSSticker) {
        self.conversation.insert(sticker) { (error) in
            if error != nil {
                print(error)
            }
        }
    }
    
    func myStickersVCShareSticker(_ sticker: MSSticker) {
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
    
    fileprivate func insertStickerIntoMessage(_ sticker: MSSticker){
        guard let image = imageFromURL(sticker.imageFileURL) else { return }
        let layout = MSMessageTemplateLayout()
        layout.image = image
        layout.caption = "Tap to save this Doodlecrop!"
        
        let message = MSMessage()
        message.layout = layout
        message.url = URLComponents(string: sticker.stickerFileName())!.url
        
        self.conversation?.insert(message, completionHandler: { (error) in
            if error != nil {
                print(error)
            }
        })
    }
    
    func onShareStickerViewSavePressed() {
        scrollToMyStickersVC(false)
        self.requestPresentationStyle(MSMessagesAppPresentationStyle.compact)
    }
    
    func generateShareStickerView() -> ShareStickerView {
        shareStickerView = ShareStickerView.instanceFromNib(self.view.frame)
        shareStickerView.delegate = self
        shareStickerView.initializeWith(conversation.selectedMessage!)
        return shareStickerView
    }
    
    fileprivate func presentCameraVC(){
        cameraVC = CameraVC()
        cameraVC.delegate = self
        cameraVC.conversation = self.conversation
        cameraVC.isMessageMode = true
        initializeViewController(self, controller: cameraVC)
    }
    
    fileprivate func presentImagePickerVC(){
        imagePickerVC = ImagePickerVC()
        imagePickerVC.delegate = self
        imagePickerVC.conversation = self.conversation
        initializeViewController(self, controller: imagePickerVC)
    }
    
    func doneSticker(_ sticker: MSSticker) {
        self.newSticker = true
        self.requestPresentationStyle(MSMessagesAppPresentationStyle.compact)
    }
    
    func finishedCreatingMessage() {
        self.dismiss()
    }
    
    func compactView() {
        self.requestPresentationStyle(MSMessagesAppPresentationStyle.compact)
    }
    
    fileprivate func removeChildViewControllersFrom(_ parent: UIViewController){
        for child in parent.childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
    }
    
    fileprivate func initializeViewController(_ parent: UIViewController, controller: UIViewController){
        
        removeChildViewControllersFrom(parent)

        parent.addChildViewController(controller)
        
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        parent.view.addSubview(controller.view)
        
        controller.view.leftAnchor.constraint(equalTo: parent.view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: parent.view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: parent.view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor).isActive = true
        
        controller.didMove(toParentViewController: self)
    }
    
    fileprivate func firebaseSignIn(){
        if FIRApp.defaultApp() == nil {
            FIRApp.configure()
        }
        if FIRAuth.auth()?.currentUser == nil {
            FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
                if error != nil {
                    print(error)
                } else {
                    print(user?.uid)
                    Crashlytics.sharedInstance().setUserIdentifier(user!.uid)
                }
            })
        }
    }
    
}
