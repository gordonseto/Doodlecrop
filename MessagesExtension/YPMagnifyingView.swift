//
//  YPMagnifyingView.swift
//  YPMagnifyingGlass
//
//  Created by Geert-Jan Nilsen on 02/06/15.
//  Copyright (c) 2015 Yuppielabel.com All rights reserved.
//

import UIKit

public class YPMagnifyingView: UIView {
  
    public var YPMagnifyingViewDefaultShowDelay: NSTimeInterval = 0.2;
  
    private var magnifyingGlassShowDelay: NSTimeInterval!
  
    private var touchTimer: NSTimer!
  
    public var magnifyingGlass: YPMagnifyingGlass = YPMagnifyingGlass()
    
    public var magnifyingGlassLocation: CGPoint!
  
    override public init(frame: CGRect) {
        self.magnifyingGlassShowDelay = YPMagnifyingViewDefaultShowDelay
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.magnifyingGlassShowDelay = YPMagnifyingViewDefaultShowDelay
        super.init(coder: aDecoder)
    }
    
    var timer: NSTimer!
    var isDrawing: Bool = false
    
    // MARK: - Touch Events
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch: UITouch = touches.first! as UITouch {
            if event?.allTouches()?.count <= 1 {
                if isDrawing {
                    self.touchTimer = NSTimer.scheduledTimerWithTimeInterval(magnifyingGlassShowDelay, target: self, selector: #selector(YPMagnifyingView.addMagnifyingGlassTimer(_:)), userInfo: NSValue(CGPoint: touch.locationInView(self)), repeats: false)
                } else {
                    timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(YPMagnifyingView.updateIsDrawing), userInfo: nil, repeats: false)
                }
            } else {
                isDrawing = false
            }
        }
    }
    
    var beginningTouch: UITouch!
    
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch: UITouch = touches.first! as UITouch {
            if event?.allTouches()?.count <= 1 {
                if isDrawing {
                    //self.updateMagnifyingGlassAtPoint(touch.locationInView(self))
                    self.addMagnifyingGlassAtPoint(touch.locationInView(self))
                } else {
                    timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(YPMagnifyingView.updateIsDrawing), userInfo: nil, repeats: false)
                }
            } else {
                isDrawing = false
            }
            
        }
    }
    
    func updateIsDrawing(){
        isDrawing = true
    }
  

    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.touchTimer.invalidate()
        self.touchTimer = nil
        
        self.removeMagnifyingGlass()
    }
  
  // MARK: - Private Functions
  
    var magnifyingGlassHasBeenAdded: Bool = false
    
    private func addMagnifyingGlassAtPoint(point: CGPoint) {
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
  
    private func removeMagnifyingGlass() {
        self.magnifyingGlass.removeFromSuperview()
    }
  
    private func updateMagnifyingGlassAtPoint(point: CGPoint) {
        self.magnifyingGlass.touchPoint = point
        self.magnifyingGlass.setNeedsDisplay()
    }
  
    public func addMagnifyingGlassTimer(timer: NSTimer) {
        let value: AnyObject? = timer.userInfo
        if let point = value?.CGPointValue() {
            self.addMagnifyingGlassAtPoint(point)
        }
    }
}
