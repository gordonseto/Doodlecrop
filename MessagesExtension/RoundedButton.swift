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
        initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize(){
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
    }
}
