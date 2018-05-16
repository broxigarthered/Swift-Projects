//
//  Functions.swift
//  Adi's Wardrobe Organizer
//
//  Created by Adelina Dutskinova on 2/2/17.
//  Copyright © 2017 Nikolay. All rights reserved.
//

import Foundation
import UIKit

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / image.size.width
    let heightRatio = targetSize.height / image.size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    let constant: CGFloat = 1
    
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: constant * (size.width * heightRatio), height: constant * (size.height * heightRatio))
    } else {
        newSize = CGSize(width: constant * (size.width * widthRatio),  height: constant * (size.height * widthRatio))
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
