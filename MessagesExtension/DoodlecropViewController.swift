//
//  DoodleCropViewController.swift
//  Doodle Crop
//
//  Created by Gordon Seto on 2016-11-17.
//  Copyright © 2016 gordonseto. All rights reserved.
//
import UIKit
import ImageFreeCut
import Messages
import MessageUI

class DoodlecropViewController: UIViewController, ImageFreeCutViewDelegate {
    
    var imageView: UIImageView!
    var drawingImageView: UIImageView!
    var cancelButton: UIButton!
    var sendButton: UIButton!
    var cutImageView: UIImageView!
    
    var cutView: ImageFreeCutView!
    
    var magnifyingView: YPMagnifyingView!
    
    var blurEffectView: UIVisualEffectView!

    var onboardView: UIView!
    var onboardLabel: UILabel!
    var shouldRemoveOnboard: Bool = false
    
    weak var delegate: MessageVCDelegate!
    var conversation: MSConversation!
    
    var imageToCrop: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func insertImage(_ image: UIImage){
        print(image)
        self.imageToCrop = image
        showImagePreview(image)
    }
    
    fileprivate func showCutImagePreview(_ image: UIImage!){
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        magnifyingView?.addSubview(blurEffectView)
        magnifyingView?.magnifyingGlass.removeFromSuperview()
        
        cutImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width * 0.6, height: self.view.frame.size.height))
        cutImageView.center = CGPoint(x: self.view.frame.size.width / 2.0, y: self.view.frame.size.height / 2.0)
        cutImageView.contentMode = UIViewContentMode.scaleAspectFit
        cutImageView.image = trimImage(image)
        self.magnifyingView?.addSubview(cutImageView)
        
        blurEffectView?.addSubview(createCancelButton(#selector(redoImageCrop)))
        blurEffectView?.addSubview(createSendButton())
        
        if shouldRemoveOnboard {
            shouldRemoveOnboard = false
            removeOnboard()
        }
    }
    
    @objc fileprivate func redoImageCrop(){
        cutImageView?.removeFromSuperview()
        blurEffectView?.removeFromSuperview()
        reinitializeMagnifyingAndCutView()
    }
    
    fileprivate func reinitializeMagnifyingAndCutView(){
        if let imageCutShapeLayer = cutView?.imageCutShapeLayer {
            cutView.imageView.layer.addSublayer(imageCutShapeLayer)
            cutView.isDrawing = false
        }
        magnifyingView?.isDrawing = false
        magnifyingView?.magnifyingGlassHasBeenAdded = false
    }
    
    fileprivate func showImagePreview(_ image: UIImage){
        self.view.addSubview(createMagnifyingView())
        
        cutView = ImageFreeCutView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        cutView.delegate = self
        cutView.imageToCut = image
        cutView.imageView.contentMode = UIViewContentMode.scaleAspectFit
        cutView.imageCutShapeLayer.strokeColor = UIColor.green.cgColor
        cutView.imageCutShapeLayer.lineWidth = 4.0
        self.magnifyingView?.addSubview(cutView)
        
        cutView.isUserInteractionEnabled = true
        
        magnifyingView.addSubview(createCancelButton(#selector(cancelImagePreview)))
        
        cutView.isMultipleTouchEnabled = true
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(DoodlecropViewController.pinchImage(_:)))
        cutView.addGestureRecognizer(pinchRecognizer)
        
        if UserDefaults.standard.object(forKey: "ZOOM_ONBOARD") == nil {
            UserDefaults.standard.set(true, forKey: "ZOOM_ONBOARD")
            shouldRemoveOnboard = true
            delay(0.2){
                self.showOnboard()
            }
        }
    }
    
    var lastScale: CGFloat = 1.0
    let K_MAX_SCALE: CGFloat = 1.6
    let K_MIN_SCALE: CGFloat = 0.9
    
    var lastPoint: CGPoint!
    
    func pinchImage(_ sender: UIPinchGestureRecognizer){
        if shouldRemoveOnboard {
            shouldRemoveOnboard = false
            removeOnboard()
        }
        
        if sender.numberOfTouches < 2 {
            return
        }
        
        if let view = sender.view {
            if sender.state == UIGestureRecognizerState.began {
                lastScale = sender.scale
                lastPoint = sender.location(in: self.view)
            }
            if sender.state == UIGestureRecognizerState.began || sender.state == UIGestureRecognizerState.changed {
                guard let currentScale = view.layer.value(forKeyPath: "transform.scale") as? CGFloat else { return }
                var newScale = 1 - (lastScale - sender.scale)
                newScale = min(newScale, K_MAX_SCALE / currentScale)
                newScale = max(newScale, K_MIN_SCALE / currentScale)
                let transform = view.transform.scaledBy(x: newScale, y: newScale)
                view.transform = transform
                lastScale = sender.scale
            }
            
            let point = sender.location(in: self.view)
            cutView.layer.setAffineTransform(cutView.layer.affineTransform().translatedBy(x: point.x - lastPoint.x, y: point.y - lastPoint.y))
            lastPoint = sender.location(in: self.view)
        }
    }
    
    /*
     * Delegate function called once image is cut
     */
    internal func imageFreeCutView(_ imageFreeCutView: ImageFreeCutView, didCut image: UIImage?){
        guard let image = image else { return }
        showCutImagePreview(image)
    }
    
    fileprivate func createMagnifyingView() -> YPMagnifyingView {
        self.magnifyingView = YPMagnifyingView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        let mag = YPMagnifyingGlass(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        mag.centerLocation = CGPoint(x: 50, y: self.view.bounds.height - 40 - MESSAGE_INPUT_HEIGHT)
        mag.scale = 1
        self.magnifyingView.magnifyingGlass = mag
        return self.magnifyingView
    }
    
    fileprivate func createCancelButton(_ cancelFunc: Selector) -> UIButton {
        cancelButton = UIButton()
        cancelButton.addTarget(self, action: cancelFunc, for: .touchUpInside)
        cancelButton.setImage(UIImage(named:"re_snap_btn"), for: UIControlState())
        cancelButton.frame.size = CGSize(width: 50, height: 50)
        cancelButton.frame.origin = CGPoint(x: 0, y: 15 + NAVIGATION_BAR_HEIGHT)
        cancelButton.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin]
        
        return cancelButton
    }
    
    fileprivate func createSendButton() -> UIButton {
        sendButton = UIButton()
        sendButton.addTarget(self, action: #selector(sendImage), for: .touchUpInside)
        sendButton.setImage(UIImage(named:"sendbutton"), for: UIControlState())
        sendButton.frame.size = CGSize(width: 60, height: 60)
        sendButton.frame.origin = CGPoint(x: self.view.bounds.width - sendButton.bounds.width - 15, y: self.view.bounds.height - sendButton.bounds.height - 15 - MESSAGE_INPUT_HEIGHT)
        sendButton.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin]
        
        return sendButton
    }
    
    @objc fileprivate func sendImage(){
        if let image = cutImageView.image {
            if let sticker = StickerManager.sharedInstance.createSticker(image) {
                self.delegate?.doneSticker(sticker)
            }
        }
    }
    
    fileprivate func trimImage(_ image: UIImage) -> UIImage? {
        let newRect = EditImage.cropRect(image)
        if let cgImage = image.cgImage {
            if let imageRef = cgImage.cropping(to: newRect) {
                let newImage = UIImage(cgImage: imageRef)
                return newImage
            }
        }
        showAlert("Oops! Something went wrong", message: "Please try another image")
        return nil
    }
    
    fileprivate func showOnboard(){
        onboardView?.removeFromSuperview()
        
        onboardView = UIView(frame: CGRect(x: 0, y: 0, width: 175, height: 35))
        onboardView.layer.cornerRadius = onboardView.frame.size.height / 2.0
        onboardView.clipsToBounds = true
        onboardView.backgroundColor = UIColor.black
        onboardView.alpha = 0.0
        onboardView.center = self.view.center
        onboardView.center.y = self.view.frame.size.height - MESSAGE_INPUT_HEIGHT - 50
        
        onboardLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
        onboardLabel.numberOfLines = 3
        onboardLabel.text = "Pinch to zoom in!"
        onboardLabel.textColor = UIColor.white
        onboardLabel.textAlignment = NSTextAlignment.center
        onboardLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        onboardLabel.center = self.onboardView.center
        onboardLabel.alpha = 0.0
        
        self.view.addSubview(onboardView)
        self.view.addSubview(onboardLabel)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.onboardLabel.alpha = 0.8
            self.onboardView.alpha = 0.8
        })
    }
    
    func removeOnboard(){
        if onboardView != nil {
            UIView.animate(withDuration: 0.2, animations: {
                    self.onboardLabel?.alpha = 0
                    self.onboardView?.alpha = 0
                }, completion:{ completed in
                    self.onboardView?.removeFromSuperview()
                    self.onboardLabel?.removeFromSuperview()
            })
        }
    }
    
    @objc internal func cancelImagePreview(_ animated: Bool = false){
        self.present(UIViewController(), animated: animated){
            self.cutView?.removeFromSuperview()
            self.cancelButton?.removeFromSuperview()
            self.sendButton?.removeFromSuperview()
            self.cutImageView?.removeFromSuperview()
            self.blurEffectView?.removeFromSuperview()
            self.removeOnboard()
        }
    }
    
    fileprivate func showAlert(_ title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel) { (action) in
            self.cancelImagePreview(true)
        }
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
}
