//
//  MyStickersVC.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2016-11-30.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import UIKit

class MyStickersVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myStickersView = MyStickersView.instanceFromNib(self.view.frame)
        self.view.addSubview(myStickersView)
    }

}
