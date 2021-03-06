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
    
    func insertImage(image: UIImage){
        print(image)
        self.imageToCrop = image
        showImagePreview(image)
    }
    
    private func showCutImagePreview(image: UIImage!){
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        magnifyingView?.addSubview(blurEffectView)
        magnifyingView?.magnifyingGlass.removeFromSuperview()
        
        cutImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width * 0.6, height: self.view.frame.size.height))
        cutImageView.center = CGPoint(x: self.view.frame.size.width / 2.0, y: self.view.frame.size.height / 2.0)
        cutImageView.contentMode = UIViewContentMode.ScaleAspectFit
        cutImageView.image = trimImage(image)
        self.magnifyingView?.addSubview(cutImageView)
        
        blurEffectView?.addSubview(createCancelButton(#selector(redoImageCrop)))
        blurEffectView?.addSubview(createSendButton())
        
        if shouldRemoveOnboard {
            shouldRemoveOnboard = false
            removeOnboard()
        }
    }
    
    @objc private func redoImageCrop(){
        cutImageView?.removeFromSuperview()
        blurEffectView?.removeFromSuperview()
        reinitializeMagnifyingAndCutView()
    }
    
    private func reinitializeMagnifyingAndCutView(){
        if let imageCutShapeLayer = cutView?.imageCutShapeLayer {
            cutView.imageView.layer.addSublayer(imageCutShapeLayer)
            cutView.isDrawing = false
        }
        magnifyingView?.isDrawing = false
        magnifyingView?.magnifyingGlassHasBeenAdded = false
    }
    
    private func showImagePreview(image: UIImage){
        self.view.addSubview(createMagnifyingView())
        
        cutView = ImageFreeCutView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        cutView.delegate = self
        cutView.imageToCut = image
        cutView.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        cutView.imageCutShapeLayer.strokeColor = UIColor.greenColor().CGColor
        cutView.imageCutShapeLayer.lineWidth = 4.0
        self.magnifyingView?.addSubview(cutView)
        
        cutView.userInteractionEnabled = true
        
        magnifyingView.addSubview(createCancelButton(#selector(cancelImagePreview)))
        
        cutView.multipleTouchEnabled = true
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(DoodlecropViewController.pinchImage(_:)))
        cutView.addGestureRecognizer(pinchRecognizer)
        
        if NSUserDefaults.standardUserDefaults().objectForKey("ZOOM_ONBOARD") == nil {
            NSUserDefaults.standardUserDefaults().setObject(true, forKey: "ZOOM_ONBOARD")
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
    
    func pinchImage(sender: UIPinchGestureRecognizer){
        if shouldRemoveOnboard {
            shouldRemoveOnboard = false
            removeOnboard()
        }
        
        if sender.numberOfTouches() < 2 {
            return
        }
        
        if let view = sender.view {
            if sender.state == UIGestureRecognizerState.Began {
                lastScale = sender.scale
                lastPoint = sender.locationInView(self.view)
            }
            if sender.state == UIGestureRecognizerState.Began || sender.state == UIGestureRecognizerState.Changed {
                guard let currentScale = view.layer.valueForKeyPath("transform.scale") as? CGFloat else { return }
                var newScale = 1 - (lastScale - sender.scale)
                newScale = min(newScale, K_MAX_SCALE / currentScale)
                newScale = max(newScale, K_MIN_SCALE / currentScale)
                let transform = CGAffineTransformScale(view.transform, newScale, newScale)
                view.transform = transform
                lastScale = sender.scale
            }
            
            let point = sender.locationInView(self.view)
            cutView.layer.setAffineTransform(CGAffineTransformTranslate(cutView.layer.affineTransform(), point.x - lastPoint.x, point.y - lastPoint.y))
            lastPoint = sender.locationInView(self.view)
        }
    }
    
    /*
     * Delegate function called once image is cut
     */
    internal func imageFreeCutView(imageFreeCutView: ImageFreeCutView, didCut image: UIImage?){
        guard let image = image else { return }
        showCutImagePreview(image)
    }
    
    private func createMagnifyingView() -> YPMagnifyingView {
        self.magnifyingView = YPMagnifyingView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        let mag = YPMagnifyingGlass(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        mag.centerLocation = CGPoint(x: 50, y: self.view.bounds.height - 40 - MESSAGE_INPUT_HEIGHT)
        mag.scale = 1
        self.magnifyingView.magnifyingGlass = mag
        return self.magnifyingView
    }
    
    private func createCancelButton(cancelFunc: Selector) -> UIButton {
        cancelButton = UIButton()
        cancelButton.addTarget(self, action: cancelFunc, forControlEvents: .TouchUpInside)
        cancelButton.setImage(UIImage(named:"re_snap_btn"), forState: .Normal)
        cancelButton.frame.size = CGSizeMake(50, 50)
        cancelButton.frame.origin = CGPoint(x: 0, y: 15 + NAVIGATION_BAR_HEIGHT)
        cancelButton.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin]
        
        return cancelButton
    }
    
    private func createSendButton() -> UIButton {
        sendButton = UIButton()
        sendButton.addTarget(self, action: #selector(sendImage), forControlEvents: .TouchUpInside)
        sendButton.setImage(UIImage(named:"sendbutton"), forState: .Normal)
        sendButton.frame.size = CGSizeMake(60, 60)
        sendButton.frame.origin = CGPoint(x: self.view.bounds.width - sendButton.bounds.width - 15, y: self.view.bounds.height - sendButton.bounds.height - 15 - MESSAGE_INPUT_HEIGHT)
        sendButton.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin]
        
        return sendButton
    }
    
    @objc private func sendImage(){
        if let image = cutImageView.image {
            if let sticker = StickerManager.sharedInstance.createSticker(image) {
                self.delegate?.doneSticker(sticker)
            }
        }
    }
    
    private func trimImage(image: UIImage) -> UIImage? {
        let newRect = EditImage.cropRect(image)
        if let cgImage = image.CGImage {
            if let imageRef = CGImageCreateWithImageInRect(cgImage, newRect) {
                let newImage = UIImage(CGImage: imageRef)
                return newImage
            }
        }
        showAlert("Oops! Something went wrong", message: "Please try another image")
        return nil
    }
    
    private func showOnboard(){
        onboardView?.removeFromSuperview()
        
        onboardView = UIView(frame: CGRect(x: 0, y: 0, width: 175, height: 35))
        onboardView.layer.cornerRadius = onboardView.frame.size.height / 2.0
        onboardView.clipsToBounds = true
        onboardView.backgroundColor = UIColor.blackColor()
        onboardView.alpha = 0.0
        onboardView.center = self.view.center
        onboardView.center.y = self.view.frame.size.height - MESSAGE_INPUT_HEIGHT - 50
        
        onboardLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
        onboardLabel.numberOfLines = 3
        onboardLabel.text = "Pinch to zoom in!"
        onboardLabel.textColor = UIColor.whiteColor()
        onboardLabel.textAlignment = NSTextAlignment.Center
        onboardLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        onboardLabel.center = self.onboardView.center
        onboardLabel.alpha = 0.0
        
        self.view.addSubview(onboardView)
        self.view.addSubview(onboardLabel)
        
        UIView.animateWithDuration(0.2, animations: {
            self.onboardLabel.alpha = 0.8
            self.onboardView.alpha = 0.8
        })
    }
    
    func removeOnboard(){
        if onboardView != nil {
            UIView.animateWithDuration(0.2, animations: {
                    self.onboardLabel?.alpha = 0
                    self.onboardView?.alpha = 0
                }, completion:{ completed in
                    self.onboardView?.removeFromSuperview()
                    self.onboardLabel?.removeFromSuperview()
            })
        }
    }
    
    @objc internal func cancelImagePreview(animated: Bool = false){
        self.presentViewController(UIViewController(), animated: animated){
            self.cutView?.removeFromSuperview()
            self.cancelButton?.removeFromSuperview()
            self.sendButton?.removeFromSuperview()
            self.cutImageView?.removeFromSuperview()
            self.blurEffectView?.removeFromSuperview()
            self.removeOnboard()
        }
    }
    
    private func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "OK", style: .Cancel) { (action) in
            self.cancelImagePreview(true)
        }
        alert.addAction(ok)
        presentViewController(alert, animated: true, completion: nil)
    }
    
}
