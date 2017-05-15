//
//  YPMagnifyingView.swift
//  YPMagnifyingGlass
//
//  Created by Geert-Jan Nilsen on 02/06/15.
//  Copyright (c) 2015 Yuppielabel.com All rights reserved.
//

import UIKit
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


open class YPMagnifyingView: UIView {
  
    open var YPMagnifyingViewDefaultShowDelay: TimeInterval = 0.2;
  
    fileprivate var magnifyingGlassShowDelay: TimeInterval!
  
    fileprivate var touchTimer: Timer!
  
    open var magnifyingGlass: YPMagnifyingGlass = YPMagnifyingGlass()
    
    open var magnifyingGlassLocation: CGPoint!
  
    override public init(frame: CGRect) {
        self.magnifyingGlassShowDelay = YPMagnifyingViewDefaultShowDelay
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.magnifyingGlassShowDelay = YPMagnifyingViewDefaultShowDelay
        super.init(coder: aDecoder)
    }
    
    var timer: Timer!
    var isDrawing: Bool = false
    
    // MARK: - Touch Events
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch: UITouch = touches.first! as UITouch {
            if event?.allTouches?.count <= 1 {
                if isDrawing {
                    self.touchTimer = Timer.scheduledTimer(timeInterval: magnifyingGlassShowDelay, target: self, selector: #selector(YPMagnifyingView.addMagnifyingGlassTimer(_:)), userInfo: NSValue(cgPoint: touch.location(in: self)), repeats: false)
                } else {
                    timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(YPMagnifyingView.updateIsDrawing), userInfo: nil, repeats: false)
                }
            } else {
                isDrawing = false
            }
        }
    }

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch: UITouch = touches.first! as UITouch {
            if event?.allTouches?.count <= 1 {
                if isDrawing {
                    //self.updateMagnifyingGlassAtPoint(touch.locationInView(self))
                    self.addMagnifyingGlassAtPoint(touch.location(in: self))
                } else {
                    timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(YPMagnifyingView.updateIsDrawing), userInfo: nil, repeats: false)
                }
            } else {
                isDrawing = false
            }
            
        }
    }
    
    func updateIsDrawing(){
        isDrawing = true
    }
  

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchTimer?.invalidate()
        self.touchTimer = nil
        
        self.removeMagnifyingGlass()
        magnifyingGlassHasBeenAdded = false
    }
  
  // MARK: - Private Functions
  
    var magnifyingGlassHasBeenAdded: Bool = false
    
    fileprivate func addMagnifyingGlassAtPoint(_ point: CGPoint) {
        if magnifyingGlassHasBeenAdded {
            updateMagnifyingGlassAtPoint(point)
        } else {
            self.magnifyingGlass.viewToMagnify = self as UIView
            self.magnifyingGlass.touchPoint = point
    
            let selfView: UIView = self as UIView!
    
            selfView.addSubview(self.magnifyingGlass)
    
            self.magnifyingGlass.setNeedsDisplay()
            magnifyingGlassHasBeenAdded = true
        }
    }
  
    fileprivate func removeMagnifyingGlass() {
        self.magnifyingGlass.removeFromSuperview()
    }
  
    fileprivate func updateMagnifyingGlassAtPoint(_ point: CGPoint) {
        self.magnifyingGlass.touchPoint = point
        self.magnifyingGlass.setNeedsDisplay()
    }
  
    open func addMagnifyingGlassTimer(_ timer: Timer) {
        let value: AnyObject? = timer.userInfo as AnyObject
        if let point = value?.cgPointValue {
            self.addMagnifyingGlassAtPoint(point)
        }
    }
}
