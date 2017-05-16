//
//  EditImage.swift
//  Image Cropper
//
//  Created by Gordon Seto on 2016-11-16.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import Foundation
import UIKit

class EditImage {
    
    static func cropRect(_ image: UIImage) -> CGRect {
        let cgImage = image.cgImage
        let context = createARGBBitmapContextFromImage(cgImage!)
        if context == nil {
            return CGRect.zero
        }
        
        let height = CGFloat(cgImage!.height)
        let width = CGFloat(cgImage!.width)
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context?.draw(cgImage!, in: rect)
        
        //let data = UnsafePointer<CUnsignedChar>(CGBitmapContextGetData(context))
        let data = context?.data?.assumingMemoryBound(to: UInt8.self)
        
        if data == nil {
            return CGRect.zero
        }
        
        var lowX = width
        var lowY = height
        var highX: CGFloat = 0
        var highY: CGFloat = 0
        
        let heightInt = Int(height)
        let widthInt = Int(width)
        //Filter through data and look for non-transparent pixels.
        for y in (0 ..< heightInt) {
            let y = CGFloat(y)
            for x in (0 ..< widthInt) {
                let x = CGFloat(x)
                let pixelIndex = (width * y + x) * 4 /* 4 for A, R, G, B */
                
                if data?[Int(pixelIndex)] != 0 { //Alpha value is not zero pixel is not transparent.
                    if (x < lowX) {
                        lowX = x
                    }
                    if (x > highX) {
                        highX = x
                    }
                    if (y < lowY) {
                        lowY = y
                    }
                    if (y > highY) {
                        highY = y
                    }
                }
            }
        }
        
        
        return CGRect(x: lowX, y: lowY, width: highX - lowY, height: highY - lowY)
    }
    
    static func createARGBBitmapContextFromImage(_ inImage: CGImage) -> CGContext? {
        
        let width = inImage.width
        let height = inImage.height
        
        let bitmapBytesPerRow = width * 4
        let bitmapByteCount = bitmapBytesPerRow * height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapData = malloc(bitmapByteCount)
        if bitmapData == nil {
            return nil
        }
 
        let context = CGContext(data: bitmapData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        return context
    }
}
