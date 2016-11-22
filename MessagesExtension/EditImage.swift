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
    
    static func cropRect(image: UIImage) -> CGRect {
        let cgImage = image.CGImage!
        let context:CGContextRef? = createARGBBitmapContextFromImage(cgImage)
        if let context = context {
            let width = Int(CGImageGetWidth(cgImage))
            let height = Int(CGImageGetHeight(cgImage))
            let rect:CGRect = CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height))
            CGContextDrawImage(context, rect, cgImage)
            
            var lowX:Int = width
            var lowY:Int = height
            var highX:Int = 0
            var highY:Int = 0
            let data:UnsafeMutablePointer<Void>? = CGBitmapContextGetData(context)
            if let data = data {
                let dataType:UnsafeMutablePointer<UInt8>? = UnsafeMutablePointer<UInt8>(data)
                if let dataType = dataType {
                    for y in 0..<height {
                        for x in 0..<width {
                            let pixelIndex:Int = (width * y + x) * 4 /* 4 for A, R, G, B */;
                            if (dataType[pixelIndex] != 0) { //Alpha value is not zero; pixel is not transparent.
                                if (x < lowX) { lowX = x };
                                if (x > highX) { highX = x };
                                if (y < lowY) { lowY = y};
                                if (y > highY) { highY = y};
                            }
                        }
                    }
                }
                free(data)
            } else {
                return CGRectZero
            }
            return CGRect(x: CGFloat(lowX), y: CGFloat(lowY), width: CGFloat(highX-lowX), height: CGFloat(highY-lowY))
            
        }
        return CGRectZero
        
    }
    
    static func createARGBBitmapContextFromImage(inImage: CGImage) -> CGContext? {
        
        let width = CGImageGetWidth(inImage)
        let height = CGImageGetHeight(inImage)
        
        let bitmapBytesPerRow = width * 4
        let bitmapByteCount = bitmapBytesPerRow * height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapData = malloc(bitmapByteCount)
        if bitmapData == nil {
            return nil
        }
 
        let context = CGBitmapContextCreate(bitmapData, width, height, 8, bitmapBytesPerRow, colorSpace, CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
        return context
    }
}
