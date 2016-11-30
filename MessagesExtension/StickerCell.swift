//
//  StickerCell.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2016-11-30.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import UIKit

class StickerCell: UICollectionViewCell {

    @IBOutlet weak var stickerName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureCell(fileName: String){
        stickerName.text = fileName
    }

}
