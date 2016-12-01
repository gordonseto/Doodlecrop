//
//  MyStickersVC.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2016-12-01.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import UIKit

class MyStickersVC: UIViewController {

    var newSticker = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myStickersView = MyStickersView.instanceFromNib(CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - MESSAGE_INPUT_HEIGHT))
        myStickersView.newSticker = newSticker
        myStickersView.initialize()
        
        self.view = myStickersView
        
    }

}
