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
        alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        let sendAction = UIAlertAction(title: "Send", style: .Default) { (UIAlertAction) in
            self.myStickersView?.unhighlightCell(self.myStickersView.selectedCell)
        }
        let shareAction = UIAlertAction(title: "Share", style: .Default) { (UIAlertAction) in
            self.myStickersView?.unhighlightCell(self.myStickersView.selectedCell)
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (UIAlertAction) in
            guard let cell = self.selectedCell else { return }
            self.deleteCell(cell)
        }
        alertController.addAction(shareAction)
        alertController.addAction(sendAction)
        alertController.addAction(deleteAction)
        alertController.view.transform = CGAffineTransformMakeTranslation(0, -40)
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
