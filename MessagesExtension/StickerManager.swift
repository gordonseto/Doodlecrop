//
//  StickerManager.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2016-11-30.
//  Copyright © 2016 Gordon Seto. All rights reserved.
//

import Foundation
import Messages
import FirebaseAuth


class StickerManager {
    
    static let sharedInstance = StickerManager()
    
    func createSticker(image: UIImage) -> MSSticker? {
        if let user = FIRAuth.auth()?.currentUser {
            let documentsDirectoryURL = try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
            
            if let folderPath = documentsDirectoryURL.URLByAppendingPathComponent("Stickers") {
                do {
                    if !NSFileManager.defaultManager().fileExistsAtPath(folderPath.path!){
                        try NSFileManager.defaultManager().createDirectoryAtPath(folderPath.path!, withIntermediateDirectories: false, attributes: nil)
                    }
                    //Create new file using user's uid and image's hashValue and save it
                    let fileName = "\(user.uid)\(NSDate().timeIntervalSince1970)"
                    let fullFileName = "\(fileName).png"
                    let fileURL = folderPath.URLByAppendingPathComponent(fullFileName)
                    
                    if let imageData = UIImagePNGRepresentation(image) {
                        
                        do {
                            try imageData.writeToFile(fileURL!.path!, options: [.AtomicWrite])
                            print("saving image to \(fileURL!.path!)")
                            do {
                                let sticker = try MSSticker(contentsOfFileURL: fileURL!, localizedDescription: "sticker")
                                addStickerToFrontOfHistory(sticker)
                                return sticker
                            } catch {
                                print("error making sticker")
                            }
                        } catch {
                            print("failed to write sticker image")
                        }
                    }
                    
                } catch let error as NSError {
                    print(error.localizedDescription);
                }
            }
        }
        return nil
    }
    
    func addStickerToFrontOfHistory(sticker: MSSticker){
        print("full File name:")
        let fullFileName = sticker.imageFileURL.lastPathComponent!
        let fileName = fullFileName.characters.dropLast(4)
        var stickerHistory = getStickerHistory()
        stickerHistory.insert(String(fileName), atIndex: 0)
        saveStickerHistory(stickerHistory)
    }
    
    func getStickerHistory() -> [String]{
        if let stickerHistory = NSUserDefaults.standardUserDefaults().objectForKey("STICKER_HISTORY") as? [String] {
            return stickerHistory
        } else {
            return []
        }
    }
    
    private func saveStickerHistory(stickerHistory: [String]) {
        NSUserDefaults.standardUserDefaults().setObject(stickerHistory, forKey: "STICKER_HISTORY")
    }
    
    func loadSticker(fileName: String) -> MSSticker? {
        let documentsDirectoryURL = try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        
        if let folderPath = documentsDirectoryURL.URLByAppendingPathComponent("Stickers") {
            let fullFileName = "\(fileName).png"
            let fileURL = folderPath.URLByAppendingPathComponent(fullFileName)
            do {
                let sticker = try MSSticker(contentsOfFileURL: fileURL!, localizedDescription: "sticker")
                return sticker
            } catch {
                print("error making sticker")
            }
        }
        
        return nil
    }
}
