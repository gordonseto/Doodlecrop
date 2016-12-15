//
//  OnboardView.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2016-12-12.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import UIKit

class OnboardView: UIView {
    
    var onboardView: UIView!
    var onboardButton: RoundedButton!
    var darkBackground: Bool = false
    
    var animationSpeed = 0.2
    
    override init(frame: CGRect) {
        super.init(frame: frame)
     
        self.backgroundColor = UIColor.clearColor()
        
    }
    
    func showOnboard(frame: CGRect, message: String){
        if darkBackground {
            let view = UIView(frame: self.frame)
            view.backgroundColor = UIColor.blackColor()
            view.alpha = 0.6
            self.addSubview(view)
        }
        
        onboardView = UIView(frame: frame)
        onboardView.center = self.center
        onboardView.backgroundColor = UIColor.blackColor()
        onboardView.alpha = 0.9
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 100))
        label.numberOfLines = 3
        label.text = message
        label.textColor = UIColor.whiteColor()
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        label.center = onboardView.center
        label.center.y -= 30
        onboardView.addSubview(label)
        
        onboardButton = RoundedButton(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
        onboardButton.backgroundColor = PINK_COLOR
        onboardButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        onboardButton.setTitle("OK!", forState: .Normal)
        onboardButton.center = onboardView.center
        onboardButton.center.y += 30
        onboardButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(OnboardView.hideOnboard))
        onboardButton.addGestureRecognizer(tapGestureRecognizer)
        onboardView.addSubview(onboardButton)
        
        self.addSubview(onboardView)
        
        onboardView.center.y += self.frame.size.height
        
        UIView.animateWithDuration(animationSpeed, animations: {
            self.onboardView.center.y -= self.frame.size.height
        })
    }
    
    func hideOnboard(){
        UIView.animateWithDuration(animationSpeed, animations: {
            self.onboardView?.center.y += self.frame.size.height
            }, completion: { completed in
                self.removeFromSuperview()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
