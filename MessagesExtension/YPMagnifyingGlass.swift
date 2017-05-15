//
//  YPMagnifyingGlass.swift
//  YPMagnifyingGlass
//
//  Created by Geert-Jan Nilsen on 02/06/15.
//  Copyright (c) 2015 Yuppielabel.com All rights reserved.
//

import UIKit
import QuartzCore

open class YPMagnifyingGlass: UIView {

  open var viewToMagnify: UIView!
  open var centerLocation: CGPoint!
  open var touchPoint: CGPoint! {
    didSet {
        self.center = centerLocation
    }
  }
  
  open var touchPointOffset: CGPoint!
  open var scale: CGFloat!
  open var scaleAtTouchPoint: Bool!
  
  open var YPMagnifyingGlassDefaultRadius: CGFloat = 40.0
  open var YPMagnifyingGlassDefaultOffset: CGFloat = -40.0
  open var YPMagnifyingGlassDefaultScale: CGFloat = 2.0
  
  open func initViewToMagnify(_ viewToMagnify: UIView, touchPoint: CGPoint, touchPointOffset: CGPoint, scale: CGFloat, scaleAtTouchPoint: Bool) {
  
    self.viewToMagnify = viewToMagnify
    self.touchPoint = touchPoint
    self.touchPointOffset = touchPointOffset
    self.scale = scale
    self.scaleAtTouchPoint = scaleAtTouchPoint
  
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  required public override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.layer.borderColor = UIColor.lightGray.cgColor
    self.layer.borderWidth = 3
    self.layer.cornerRadius = frame.size.width / 2
    self.layer.masksToBounds = true
    self.touchPointOffset = CGPoint(x: 0, y: YPMagnifyingGlassDefaultOffset)
    self.scale = YPMagnifyingGlassDefaultScale
    self.viewToMagnify = nil
    self.scaleAtTouchPoint = true
  }
  
  fileprivate func setFrame(_ frame: CGRect) {
    super.frame = frame
    self.layer.cornerRadius = frame.size.width / 2
  }
  
  open override func draw(_ rect: CGRect) {
    let context: CGContext = UIGraphicsGetCurrentContext()!
    context.translateBy(x: self.frame.size.width/2, y: self.frame.size.height/2)
    context.scaleBy(x: self.scale, y: self.scale)
    context.translateBy(x: -self.touchPoint.x, y: -self.touchPoint.y + (self.scaleAtTouchPoint != nil ? 0 : self.bounds.size.height/2))
    self.viewToMagnify.layer.render(in: context)
  }
}
