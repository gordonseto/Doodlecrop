//
//  MyStickersVC.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2016-11-30.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import UIKit

class MyStickersVC: UIViewController, MyStickersViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myStickersView = MyStickersView.instanceFromNib(CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - MESSAGE_INPUT_HEIGHT))
        myStickersView.delegate = self
        self.view.addSubview(myStickersView)
        myStickersView.initialize()
    }
    
    func dismissMyStickerView() {
        if let nav = self.navigationController {
            nav.popViewControllerAnimated(true)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

}
