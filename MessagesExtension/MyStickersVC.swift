//
//  MyStickersVC.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2016-12-01.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import UIKit

protocol MyStickersVCDelegate {
    func myStickersVCHomeButtonPressed()
    func myStickersNewStickerButtonPressed()
}

class MyStickersVC: UIViewController, MyStickersViewDelegate {
    
    var myStickersView: MyStickersView!
    
    var delegate: MyStickersVCDelegate!
    
    var alertController: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myStickersView = MyStickersView.instanceFromNib(CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - MESSAGE_INPUT_HEIGHT))
        myStickersView.initialize()
        myStickersView.delegate = self.delegate
        myStickersView.controllerDelegate = self
        self.view.addSubview(myStickersView)
        
    }
    
    func reloadStickers(){
        myStickersView?.newSticker = true
        myStickersView?.loadStickers()
    }
    
    func onMyStickersViewStickerTapped(cell: StickerCell) {
        self.presentViewController(createAlertController(), animated: true){
            self.alertController?.view.superview?.subviews[1].userInteractionEnabled = true
            self.alertController?.view.superview?.subviews[1].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }
    
    private func createAlertController() -> UIAlertController {
        alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        let cameraVCAction = UIAlertAction(title: "Camera", style: .Default) { (UIAlertAction) in
            self.myStickersView?.unhighlightCell(self.myStickersView.selectedCell)
        }
        let imagePickerVCAction = UIAlertAction(title: "Photo Library", style: .Default) { (UIAlertAction) in
            self.myStickersView?.unhighlightCell(self.myStickersView.selectedCell)
        }
        alertController.addAction(imagePickerVCAction)
        alertController.addAction(cameraVCAction)
        alertController.view.transform = CGAffineTransformMakeTranslation(0, -40)
        return alertController
    }
    
    @objc private func alertControllerBackgroundTapped()
    {
        myStickersView?.unhighlightCell(myStickersView.selectedCell)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
