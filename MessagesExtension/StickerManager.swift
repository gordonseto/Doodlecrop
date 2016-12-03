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
    
    func createSticker(var image: UIImage) -> MSSticker? {
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
                    
                    if image.size.width > 300 || image.size.height > 300 {
                        image = resizeImage(image, targetSize: CGSize(width: 300, height: 300))
                    }
                    
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
    
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
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
    
    func deleteSticker(fullFileName: String) {
        let documentsDirectoryURL = try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        
        if let folderPath = documentsDirectoryURL.URLByAppendingPathComponent("Stickers") {
            guard let fileURL = folderPath.URLByAppendingPathComponent(fullFileName) else { return }
            do {
                var stickerHistory = getStickerHistory()
                let fileName = String(fullFileName.characters.dropLast(4))
                print(fileName)
                guard let index = stickerHistory.indexOf(fileName) else { return }
                stickerHistory.removeAtIndex(index)
                saveStickerHistory(stickerHistory)
                print("delete \(fullFileName)")
                try NSFileManager.defaultManager().removeItemAtURL(fileURL)
            } catch {
                print("error deleting sticker")
            }
        }
    }
}
