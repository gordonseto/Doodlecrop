//
//  RoundedButton.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2016-12-03.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    override func awakeFromNib() {
        self.layer.cornerRadius = self.bounds.size.height * 0.5
        self.clipsToBounds = true
        self.layer.backgroundColor = UIColor.clearColor().CGColor
        self.layer.borderWidth = 3.0
        self.layer.borderColor = UIColor.redColor().CGColor
        self.setTitleColor(UIColor.redColor(), forState: .Normal)
    }

}
