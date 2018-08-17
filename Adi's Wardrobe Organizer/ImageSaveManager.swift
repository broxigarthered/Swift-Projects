//
//  ImageSaveManager.swift
//  Adi's Wardrobe Organizer
//
//  Created by Nikolay on 2/20/17.
//  Copyright © 2017 Nikolay. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class ImageSaveManager{
    static let sharedInstance = ImageSaveManager()
    
    func getImage(_ atIndex: Int, _ imageName: String) -> UIImage {
        
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        
        let pathsNSURL = URL(string: paths)
        
        if !SDWebImageManager.shared().cachedImageExists(for: pathsNSURL) {
            let imageToSet = UIImage(contentsOfFile: paths)
            SDWebImageManager.shared().saveImage(toCache: imageToSet, for: URL(string: paths))
        }
        
        let imageViewToReturn = UIImage(contentsOfFile: paths)
        
        return imageViewToReturn!
    }

    
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func saveImageDocumentDirectory(image: UIImage, imageName: String){
        let fileManager = FileManager.default
        // print(paths)
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        
        let imageData = UIImageJPEGRepresentation(image, 0.2)
        
        if !fileManager.fileExists(atPath: paths) {
            fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
        }
    }
    
    func getImage(imageName: String) -> UIImage{
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        var image = UIImage()
        
        if fileManager.fileExists(atPath: imagePath){
            image = UIImage(contentsOfFile: imagePath)!
            return image
        }
        print("no image")
        return image
    }
    
    func removeImage(itemName:String) {
        let fileManager = FileManager.default
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        guard let dirPath = paths.first else {
            return
        }
        let filePath = "\(dirPath)/\(itemName)"
        do {
            try fileManager.removeItem(atPath: filePath)
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
    
    func generateImageName() -> String {
        let date: NSDate = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'_'HH_mm_ss_SS"
        dateFormatter.timeZone = NSTimeZone(name: "GMT") as TimeZone!
        let imageName = "/\(dateFormatter.string(from: date as Date))"
        
        return imageName
    }
    
    func cacheImage(imageName: String){
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        
        let pathsNSURL = URL(string: paths)
        let imageToSet = UIImage(contentsOfFile: paths)
        
        if !SDWebImageManager.shared().cachedImageExists(for: pathsNSURL) {
            SDWebImageManager.shared().saveImage(toCache: imageToSet, for: URL(string: paths))
        }
    }
}
