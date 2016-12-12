//
//  ImageFreeCutView.swift
//  ImageFreeCut
//
//  Created by Cem Olcay on 17/10/16.
//  Copyright © 2016 Mojilala. All rights reserved.
//

import UIKit
import QuartzCore

public protocol ImageFreeCutViewDelegate: class {
    func imageFreeCutView(imageFreeCutView: ImageFreeCutView, didCut image: UIImage?)
}

public class ImageFreeCutView: UIView {
    public var imageView: UIImageView!
    public var imageCutShapeLayer: CAShapeLayer!
    
    public weak var delegate: ImageFreeCutViewDelegate?
    public var imageToCut: UIImage? {
        didSet {
            imageView.image = imageToCut
        }
    }
    
    private var drawPoints: [CGPoint] = [] {
        didSet {
            drawShape()
        }
    }
    
    // MARK: Init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        // Setup image view
        imageView = UIImageView(frame: frame)
        addSubview(imageView)
        imageView.image = imageToCut
        imageView.userInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        imageView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        imageView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        imageView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        
        // Setup image cut shape layer
        imageCutShapeLayer = CAShapeLayer()
        imageCutShapeLayer.frame = imageView.bounds
        imageCutShapeLayer.fillColor = UIColor.clearColor().CGColor
        imageCutShapeLayer.lineWidth = 1
        imageCutShapeLayer.strokeColor = UIColor.blackColor().CGColor
        imageCutShapeLayer.lineJoin = kCALineJoinRound
        imageCutShapeLayer.lineDashPattern = [4, 4]
        imageView.layer.addSublayer(imageCutShapeLayer)
    }
    
    // MARK: Lifecycle
    override public func layoutSubviews() {
        super.layoutSubviews()
        imageCutShapeLayer.frame = imageView.bounds
    }
    
    // MARK: Touch Handling
    
    public var timer: NSTimer!
    public var isDrawing: Bool = false
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        handleTouch(touches, event: event)
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        
        handleTouch(touches, event: event)
    }
    
    func handleTouch(touches: Set<UITouch>, event: UIEvent?){
        
        if event?.allTouches()?.count <= 1 {
            if isDrawing{
                guard let touchPosition = touches.first?.locationInView(imageView) else { return }
                drawPoints.append(touchPosition)
            } else {
                timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(ImageFreeCutView.updateIsDrawing), userInfo: nil, repeats: false)
            }
        } else {
            isDrawing = false
        }
    }
    
    func updateIsDrawing(){
        isDrawing = true
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        
        if event?.allTouches()?.count <= 1 {
            guard let touchPosition = touches.first?.locationInView(imageView) else { return }
            drawPoints.append(touchPosition)
        
            // Close path
            guard let cgPath = imageCutShapeLayer.path else { return }
            let path = UIBezierPath(CGPath: cgPath)
            path.closePath()
            imageCutShapeLayer.path = path.CGPath
        
            // Notify delegate
            delegate?.imageFreeCutView(self, didCut: cropImage())
            resetShape()
        }
    }
    
    // MARK: Cutting Crew
    private func resetShape() {
        drawPoints = []
        imageView.layer.mask = nil
    }
    
    private func drawShape() {
        if drawPoints.isEmpty {
            imageCutShapeLayer.path = nil
            return
        }
        
        let path = UIBezierPath()
        for (index, point) in drawPoints.enumerate() {
            if index == 0 {
                path.moveToPoint(point)
            } else {
                path.addLineToPoint(point)
            }
        }
        
        imageCutShapeLayer.path = path.CGPath
    }
    
    private func cropImage() -> UIImage? {
        guard let originalImage = imageToCut, let cgPath = imageCutShapeLayer.path else { return nil }
        
//        let path = UIBezierPath(CGPath: cgPath)
//        UIGraphicsBeginImageContextWithOptions(imageView.frame.size, false, 0)
//        path.addClip()
//        originalImage.drawInRect(imageView.bounds)
//        
//        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return croppedImage
        
        let path = UIBezierPath(CGPath: cgPath)
        path.addClip()
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        imageView.layer.mask = shapeLayer
        imageCutShapeLayer.removeFromSuperlayer()
        
        UIGraphicsBeginImageContextWithOptions(imageView.frame.size, false, 0)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedImage
    }
}
