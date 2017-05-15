//
//  ImageFreeCutView.swift
//  ImageFreeCut
//
//  Created by Cem Olcay on 17/10/16.
//  Copyright © 2016 Mojilala. All rights reserved.
//

import UIKit
import QuartzCore
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


public protocol ImageFreeCutViewDelegate: class {
    func imageFreeCutView(_ imageFreeCutView: ImageFreeCutView, didCut image: UIImage?)
}

open class ImageFreeCutView: UIView {
    open var imageView: UIImageView!
    open var imageCutShapeLayer: CAShapeLayer!
    
    open weak var delegate: ImageFreeCutViewDelegate?
    open var imageToCut: UIImage? {
        didSet {
            imageView.image = imageToCut
        }
    }
    
    fileprivate var drawPoints: [CGPoint] = [] {
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
    
    fileprivate func commonInit() {
        // Setup image view
        imageView = UIImageView(frame: frame)
        addSubview(imageView)
        imageView.image = imageToCut
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        // Setup image cut shape layer
        imageCutShapeLayer = CAShapeLayer()
        imageCutShapeLayer.frame = imageView.bounds
        imageCutShapeLayer.fillColor = UIColor.clear.cgColor
        imageCutShapeLayer.lineWidth = 1
        imageCutShapeLayer.strokeColor = UIColor.black.cgColor
        imageCutShapeLayer.lineJoin = kCALineJoinRound
        imageCutShapeLayer.lineDashPattern = [4, 4]
        imageView.layer.addSublayer(imageCutShapeLayer)
    }
    
    // MARK: Lifecycle
    override open func layoutSubviews() {
        super.layoutSubviews()
        imageCutShapeLayer.frame = imageView.bounds
    }
    
    // MARK: Touch Handling
    
    open var timer: Timer!
    open var isDrawing: Bool = false
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        handleTouch(touches, event: event)
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        handleTouch(touches, event: event)
    }
    
    func handleTouch(_ touches: Set<UITouch>, event: UIEvent?){
        
        if event?.allTouches?.count <= 1 {
            if isDrawing{
                guard let touchPosition = touches.first?.location(in: imageView) else { return }
                drawPoints.append(touchPosition)
            } else {
                timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ImageFreeCutView.updateIsDrawing), userInfo: nil, repeats: false)
            }
        } else {
            isDrawing = false
        }
    }
    
    func updateIsDrawing(){
        isDrawing = true
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if event?.allTouches?.count <= 1 {
            guard let touchPosition = touches.first?.location(in: imageView) else { return }
            drawPoints.append(touchPosition)
        
            // Close path
            guard let cgPath = imageCutShapeLayer.path else { return }
            let path = UIBezierPath(cgPath: cgPath)
            path.close()
            imageCutShapeLayer.path = path.cgPath
        
            // Notify delegate
            delegate?.imageFreeCutView(self, didCut: cropImage())
            resetShape()
        }
    }
    
    // MARK: Cutting Crew
    fileprivate func resetShape() {
        drawPoints = []
        imageView.layer.mask = nil
    }
    
    fileprivate func drawShape() {
        if drawPoints.isEmpty {
            imageCutShapeLayer.path = nil
            return
        }
        
        let path = UIBezierPath()
        for (index, point) in drawPoints.enumerated() {
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        imageCutShapeLayer.path = path.cgPath
    }
    
    fileprivate func cropImage() -> UIImage? {
        guard let originalImage = imageToCut, let cgPath = imageCutShapeLayer.path else { return nil }
        
//        let path = UIBezierPath(CGPath: cgPath)
//        UIGraphicsBeginImageContextWithOptions(imageView.frame.size, false, 0)
//        path.addClip()
//        originalImage.drawInRect(imageView.bounds)
//        
//        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return croppedImage
        
        let path = UIBezierPath(cgPath: cgPath)
        path.addClip()
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        imageView.layer.mask = shapeLayer
        imageCutShapeLayer.removeFromSuperlayer()
        
        UIGraphicsBeginImageContextWithOptions(imageView.frame.size, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            imageView.layer.render(in: context)
            let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return croppedImage
        } else {
             return nil
        }
    }
}
