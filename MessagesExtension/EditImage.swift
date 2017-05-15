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
        let cgImage = image.cgImage!
        let context:CGContext? = createARGBBitmapContextFromImage(cgImage)
        if let context = context {
            let width = Int(cgImage.width)
            let height = Int(cgImage.height)
            let rect:CGRect = CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height))
            context.draw(cgImage, in: rect)
            
            var lowX:Int = width
            var lowY:Int = height
            var highX:Int = 0
            var highY:Int = 0
            let data:UnsafeMutableRawPointer? = context.data
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
                return CGRect.zero
            }
            return CGRect(x: CGFloat(lowX), y: CGFloat(lowY), width: CGFloat(highX-lowX), height: CGFloat(highY-lowY))
            
        }
        return CGRect.zero
        
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
