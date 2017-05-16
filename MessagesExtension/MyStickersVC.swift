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
    func myStickersVCSendSticker(_ sticker: MSSticker)
    func myStickersVCShareSticker(_ sticker: MSSticker)
}

class MyStickersVC: UIViewController, MyStickersViewDelegate {
    
    var myStickersView: MyStickersView!
    
    var delegate: MyStickersVCDelegate!
    
    var alertController: UIAlertController!
    
    var selectedCell: StickerCell!
    
    var loadingView: UIView!
    var loadingLabel: UILabel!
    var loadingIndicator: UIActivityIndicatorView!
    
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
    
    func onMyStickersViewStickerTapped(_ cell: StickerCell) {
        self.present(createAlertController(), animated: true){
            self.selectedCell = cell
            self.alertController?.view.superview?.subviews[1].isUserInteractionEnabled = true
            self.alertController?.view.superview?.subviews[1].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }
    
    fileprivate func createAlertController() -> UIAlertController {
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad { //user is on iPad
            alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        } else {
            alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        }
        let sendAction = UIAlertAction(title: "Send", style: .default) { (UIAlertAction) in
            guard let cell = self.selectedCell else { return }
            self.delegate?.myStickersVCSendSticker(cell.stickerView.sticker!)
            self.myStickersView?.unhighlightCell(self.myStickersView.selectedCell)
        }
        let shareAction = UIAlertAction(title: "Share", style: .default) { (UIAlertAction) in
            guard let cell = self.selectedCell else { return }
            self.generateLoadingView()
            self.delegate?.myStickersVCShareSticker(cell.stickerView.sticker!)
            self.myStickersView?.unhighlightCell(self.myStickersView.selectedCell)
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (UIAlertAction) in
            guard let cell = self.selectedCell else { return }
            self.deleteCell(cell)
        }
        alertController.addAction(shareAction)
        alertController.addAction(sendAction)
        alertController.addAction(deleteAction)
        alertController.view.transform = CGAffineTransform(translationX: 0, y: -34)
        return alertController
    }
    
    func generateLoadingView() {
        
        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: 110, height: 110))
        loadingView.layer.cornerRadius = 5.0
        loadingView.clipsToBounds = true
        loadingView.center = self.myStickersView.center
        loadingView.backgroundColor = UIColor.black
        loadingView.alpha = 0.0
        self.myStickersView.addSubview(loadingView)
        
        loadingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        loadingLabel.text = "Generating..."
        loadingLabel.textColor = UIColor.white
        loadingLabel.textAlignment = NSTextAlignment.center
        loadingLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        loadingLabel.center = self.myStickersView.center
        loadingLabel.center.y += 15
        loadingLabel.alpha = 0.0
        
        self.myStickersView.addSubview(loadingLabel)
        
        loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        loadingIndicator.center = self.myStickersView.center
        loadingIndicator.center.y -= 15
        self.myStickersView.addSubview(loadingIndicator)
        loadingIndicator.alpha = 0.0
        loadingIndicator.startAnimating()

        UIView.animate(withDuration: 0.1, animations: {
            self.loadingView.alpha = 0.9
            self.loadingLabel.alpha = 0.9
            self.loadingIndicator.alpha = 0.9
        })
    }
    
    func removeLoadingView(){
        loadingView?.removeFromSuperview()
        loadingLabel?.removeFromSuperview()
        loadingIndicator?.removeFromSuperview()
    }
    
    fileprivate func deleteCell(_ cell: StickerCell){
        let stickerFullFileName = cell.stickerView.sticker!.imageFileURL.lastPathComponent
        StickerManager.sharedInstance.deleteSticker(stickerFullFileName)
        guard let index = myStickersView.stickerHistory.index(of: (String(stickerFullFileName.characters.dropLast(4)))) else { return }
        myStickersView.stickerHistory.remove(at: index)
        let indexPath = IndexPath(item: index, section: 0)
        myStickersView.collectionView.deleteItems(at: [indexPath])
    }
    
    @objc fileprivate func alertControllerBackgroundTapped()
    {
        myStickersView?.unhighlightCell(myStickersView.selectedCell)
        self.dismiss(animated: true, completion: nil)
    }

}
