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
    
    var onboardView: OnboardView!
    
    var delegate: MessageVCDelegate!
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
        pinchRecognizer.delegate = cutView
        cutView.addGestureRecognizer(pinchRecognizer)
        
        let dragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DoodlecropViewController.dragImage(_:)))
        dragRecognizer.minimumNumberOfTouches = 2
        dragRecognizer.delegate = cutView
        cutView.addGestureRecognizer(dragRecognizer)
        
    }
    
    var lastScale: CGFloat = 1.0
    let K_MAX_SCALE: CGFloat = 1.5
    let K_MIN_SCALE: CGFloat = 0.9
    
    func pinchImage(sender: UIPinchGestureRecognizer){
        if let view = sender.view {
            if sender.state == UIGestureRecognizerState.Began {
                lastScale = sender.scale
            }
            if sender.state == UIGestureRecognizerState.Began || sender.state == UIGestureRecognizerState.Changed {
                guard let currentScale = view.layer.valueForKeyPath("transform.scale") as? CGFloat else { return }
                var newScale = 1 - (lastScale - sender.scale)
                newScale = min(newScale, K_MAX_SCALE / currentScale)
                newScale = max(newScale, K_MIN_SCALE / currentScale)
                let transform = CGAffineTransformScale(view.transform, newScale, newScale)
                view.transform = transform
                lastScale = sender.scale
//            view.transform = CGAffineTransformScale(view.transform, sender.scale, sender.scale)
//            sender.scale = 1
            }
        }
    }
    
    var panCoord: CGPoint!
    
    func dragImage(sender: UIPanGestureRecognizer){
//        if let view = sender.view {
//            if sender.state == UIGestureRecognizerState.Began {
//                self.panCoord = sender.locationInView(view)
//            }
//        }
        let translation = sender.translationInView(self.view)
        sender.view?.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
        sender.setTranslation(CGPointZero, inView: self.view)
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
    
    private func trimImage(image: UIImage) -> UIImage {
        let newRect = EditImage.cropRect(image)
        let imageRef = CGImageCreateWithImageInRect(image.CGImage!, newRect)!
        let newImage = UIImage(CGImage: imageRef)
        
        return newImage
    }
    
    private func showOnboard(){
        onboardView?.removeFromSuperview()
        
        onboardView = OnboardView(frame: self.view.frame)
        onboardView.darkBackground = true
        self.view.addSubview(onboardView)
        onboardView.showOnboard(CGRectMake(0, 0, 300, 300), message: "This is a test")
    }
    
    @objc internal func cancelImagePreview(){
        self.presentViewController(UIViewController(), animated: false){
            self.cutView?.removeFromSuperview()
            self.cancelButton?.removeFromSuperview()
            self.sendButton?.removeFromSuperview()
            self.cutImageView?.removeFromSuperview()
        }
    }
    
}

extension ImageFreeCutView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return true
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
