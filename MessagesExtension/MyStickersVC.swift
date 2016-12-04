//
//  MyStickersVC.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2016-12-01.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import UIKit
import Messages

protocol MyStickersVCDelegate {
    func myStickersVCHomeButtonPressed()
    func myStickersNewStickerButtonPressed()
    func myStickersVCSendSticker(sticker: MSSticker)
    func myStickersVCShareSticker(sticker: MSSticker)
}

class MyStickersVC: UIViewController, MyStickersViewDelegate {
    
    var myStickersView: MyStickersView!
    
    var delegate: MyStickersVCDelegate!
    
    var alertController: UIAlertController!
    
    var selectedCell: StickerCell!
    
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
            self.selectedCell = cell
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
        let sendAction = UIAlertAction(title: "Send", style: .Default) { (UIAlertAction) in
            guard let cell = self.selectedCell else { return }
            self.delegate?.myStickersVCSendSticker(cell.stickerView.sticker!)
            self.myStickersView?.unhighlightCell(self.myStickersView.selectedCell)
        }
        let shareAction = UIAlertAction(title: "Share", style: .Default) { (UIAlertAction) in
            guard let cell = self.selectedCell else { return }
            self.delegate?.myStickersVCShareSticker(cell.stickerView.sticker!)
            self.myStickersView?.unhighlightCell(self.myStickersView.selectedCell)
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (UIAlertAction) in
            guard let cell = self.selectedCell else { return }
            self.deleteCell(cell)
        }
        alertController.addAction(shareAction)
        alertController.addAction(sendAction)
        alertController.addAction(deleteAction)
        alertController.view.transform = CGAffineTransformMakeTranslation(0, -34)
        return alertController
    }
    
    private func deleteCell(cell: StickerCell){
        guard let stickerFullFileName = cell.stickerView.sticker!.imageFileURL.lastPathComponent else { return }
        StickerManager.sharedInstance.deleteSticker(stickerFullFileName)
        guard let index = myStickersView.stickerHistory.indexOf((String(stickerFullFileName.characters.dropLast(4)))) else { return }
        myStickersView.stickerHistory.removeAtIndex(index)
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        myStickersView.collectionView.deleteItemsAtIndexPaths([indexPath])
    }
    
    @objc private func alertControllerBackgroundTapped()
    {
        myStickersView?.unhighlightCell(myStickersView.selectedCell)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
