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
import FirebaseDatabase
import FirebaseStorage

class StickerManager {
    
    static let sharedInstance = StickerManager()
    
    func createSticker(_ image: UIImage) -> MSSticker? {
        if let user = FIRAuth.auth()?.currentUser {
            let fileName = "\(user.uid)&\(image.hashValue)"
            return saveSticker(fileName, image: image)
        } else {
            return nil
        }
    }
    
    func saveSticker(_ fileName: String, image: UIImage) -> MSSticker? {
        var image = image
        let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let folderPath = documentsDirectoryURL.appendingPathComponent("Stickers")
        do {
            if !FileManager.default.fileExists(atPath: folderPath.path){
                try FileManager.default.createDirectory(atPath: folderPath.path, withIntermediateDirectories: false, attributes: nil)
            }
            //Create new file using user's uid and image's hashValue and save it
            let fullFileName = "\(fileName).png"
            let fileURL = folderPath.appendingPathComponent(fullFileName)
            
            if image.size.width > 300 || image.size.height > 300 {
                image = resizeImage(image, targetSize: CGSize(width: 300, height: 300))
            }
            
            if let imageData = UIImagePNGRepresentation(image) {
                
                do {
                    try imageData.write(to: URL(fileURLWithPath: fileURL.path), options: [.atomicWrite])
                    print("saving image to \(fileURL.path)")
                    do {
                        let sticker = try MSSticker(contentsOfFileURL: fileURL, localizedDescription: "sticker")
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
        
        
        return nil
    }
    
    fileprivate func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func addStickerToFrontOfHistory(_ sticker: MSSticker){
        let fileName = sticker.stickerFileName()
        var stickerHistory = getStickerHistory()
        if let index = stickerHistory.index(of: String(fileName)) {
            stickerHistory.remove(at: index)
        }
        stickerHistory.insert(String(fileName), at: 0)
        saveStickerHistory(stickerHistory)
    }
    
    func getStickerHistory() -> [String]{
        if let stickerHistory = UserDefaults.standard.object(forKey: "STICKER_HISTORY") as? [String] {
            return stickerHistory
        } else {
            return []
        }
    }
    
    fileprivate func saveStickerHistory(_ stickerHistory: [String]) {
        UserDefaults.standard.set(stickerHistory, forKey: "STICKER_HISTORY")
    }
    
    func loadSticker(_ fileName: String) -> MSSticker? {
        let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let folderPath = documentsDirectoryURL.appendingPathComponent("Stickers")
            let fullFileName = "\(fileName).png"
            let fileURL = folderPath.appendingPathComponent(fullFileName)
            do {
                let sticker = try MSSticker(contentsOfFileURL: fileURL, localizedDescription: "sticker")
                return sticker
            } catch {
                print("error making sticker")
            }
        
        
        return nil
    }
    
    func deleteSticker(_ fullFileName: String) {
        let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let folderPath = documentsDirectoryURL.appendingPathComponent("Stickers")
            let fileURL = folderPath.appendingPathComponent(fullFileName)
            do {
                var stickerHistory = getStickerHistory()
                let fileName = String(fullFileName.characters.dropLast(4))
                print(fileName)
                guard let index = stickerHistory.index(of: fileName) else { return }
                stickerHistory.remove(at: index)
                saveStickerHistory(stickerHistory)
                print("delete \(fullFileName)")
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                print("error deleting sticker")
            }
        
    }
    
    func uploadSticker(_ sticker: MSSticker, completion:@escaping (URL)->()) {
        guard let user = FIRAuth.auth()?.currentUser else { return }
        
        let storage = FIRStorage.storage().reference(forURL: FIREBASE_STORAGE_URL).child("images").child(sticker.stickerFileName())
        if let imageData = UIImagePNGRepresentation(imageFromURL(sticker.imageFileURL)!) {
            storage.put(imageData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print(error)
                } else {
                    let time = Date().timeIntervalSince1970
                    let firebase = FIRDatabase.database().reference()
                    firebase.child("users").child(user.uid).child("stickers").child(sticker.stickerFileName()).setValue(time)
                    firebase.child("stickers").child(sticker.stickerFileName()).child("url").setValue(metadata!.downloadURL()!.absoluteString)
                    completion(metadata!.downloadURL()!)
                }
            }
        }
    }
    
    func checkIfStickerExists(_ sticker: MSSticker, completion:@escaping (Bool)->()){
        let firebase = FIRDatabase.database().reference()
        firebase.child("stickers").child(sticker.stickerFileName()).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            if let _ = (snapshot.value as? AnyObject)?["url"] as? URL {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    func downloadSticker(_ url: URL, completion:@escaping (UIImage)->()) {
        let imageReference = FIRStorage.storage().reference(forURL: FIREBASE_STORAGE_URL).child("images").child(url.absoluteString)
        
        imageReference.data(withMaxSize: 1 * 1024 * 1024) { (data, error) in
            if error != nil {
                print(error)
            } else {
                if let image = UIImage(data: data!) {
                    completion(image)
                }
            }
        }
    }
    
}
