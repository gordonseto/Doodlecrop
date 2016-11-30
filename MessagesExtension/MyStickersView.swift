//
//  MyStickersView.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2016-11-30.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import UIKit

class MyStickersView: UIView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func instanceFromNib(frame: CGRect) -> MyStickersView {
        let view = UINib(nibName: "MyStickersView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MyStickersView
        view.frame = frame
        return view
    }

}
