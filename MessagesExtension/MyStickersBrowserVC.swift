//
//  MyStickersBrowserVC.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2016-11-30.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import UIKit
import Messages

class MyStickersBrowserVC: MSStickerBrowserViewController {

    var stickerHistory: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stickerHistory = StickerManager.sharedInstance.getStickerHistory()
    }

    override func numberOfStickersInStickerBrowserView(stickerBrowserView: MSStickerBrowserView) -> Int {
        return stickerHistory.count
    }
    
    override func stickerBrowserView(stickerBrowserView: MSStickerBrowserView, stickerAtIndex index: Int) -> MSSticker {
        let sticker = StickerManager.sharedInstance.loadSticker(stickerHistory[index])
        return sticker!
    }

}
