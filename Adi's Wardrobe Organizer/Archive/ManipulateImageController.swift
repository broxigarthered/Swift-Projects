//
//  ManipulateImageController.swift
//  Adi's Wardrobe Organizer
//
//  Created by Nikolay on 4/25/16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

import UIKit
import CoreData

class ManipulateImageController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var browseCollectionButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet var backgroundImage: UIImageView!
    
    var hasChosenImage: Bool = false
    var clothImage: UIImageView!
    var currentDefaultImage: UIImage!
    
    var cloth: ClothMO!
    var clothImageMO: ClothImageMO!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        // self.backgroundImage.addSubview(blurEffectView)
        
        self.view.insertSubview(blurEffectView, aboveSubview: backgroundImage)
        
        backgroundImage.image = currentDefaultImage
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // MARK: Cut image once
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        var temporalImage = image.mediumQualityJPEGNSData
        
        if temporalImage.count/1024 > 400 {
            let customImage = UIImage(data: temporalImage)
            temporalImage = customImage!.lowQualityJPEGNSData
        }
        
        backgroundImage.image = UIImage(data: temporalImage)
        
        print("image that we set in manage controller: %f",temporalImage.count/1024)
        
        saveData(UIImage(data: temporalImage)!)
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func takePhoto(_ sender: AnyObject) {
        
        // check whether the cell is selected if it isn't call the imagePicker, if it is delete the image
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        hasChosenImage = true
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func browseLibrary(_ sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        hasChosenImage = true
        
        self.present(imagePicker, animated: true, completion: nil)
        //performSegueWithIdentifier("manipulateImageSegue", sender: sender)
    }
    
    func saveData(_ image: UIImage){
        
        let defaults = UserDefaults.standard
        
        let currentSeason = defaults.value(forKey: "currentSeason")
        let currentClothType = defaults.value(forKey: "currentClothType")
        
        
        // 1. moc = managed object context
        if let moc = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
            
            // 2. inserting and modifying the data
            cloth = NSEntityDescription.insertNewObject(forEntityName: "Cloth", into: moc) as! ClothMO
            
            cloth.isSelected = false
            cloth.clothType = currentClothType as! String
            cloth.seasonName = currentSeason as! String
            
            clothImageMO = NSEntityDescription.insertNewObject(forEntityName: "ClothImage", into: moc) as! ClothImageMO
            clothImageMO.cloth = cloth
            
            // MARK: Cutting the image quality second time
            var temporalImage = UIImagePNGRepresentation(image)!
            
            if temporalImage.count/1024 > 500 {
                let customImage = UIImage(data: temporalImage)
                temporalImage = customImage!.lowQualityJPEGNSData
            }
          
            clothImageMO.image = temporalImage
            
            cloth.setValue(clothImageMO, forKey: "imageTest")
            
//            let imageSize: Int = (clothImageMO.image?.length)!
//            print("size of image in KB: %f ", imageSize / 1024)
            
            // 3. save the data
            do {
                try moc.save()
            } catch {
                print(error)
                return
            }
            
        }
    }
    
}

// MARK: Extensions
extension UIImage {
    var uncompressedPNGData: Data      { return UIImagePNGRepresentation(self)!        }
    var highestQualityJPEGNSData: Data { return UIImageJPEGRepresentation(self, 1.0)!  }
    var highQualityJPEGNSData: Data    { return UIImageJPEGRepresentation(self, 0.75)! }
    var mediumQualityJPEGNSData: Data  { return UIImageJPEGRepresentation(self, 0.5)!  }
    var lowQualityJPEGNSData: Data     { return UIImageJPEGRepresentation(self, 0.25)! }
    var lowestQualityJPEGNSData:Data   { return UIImageJPEGRepresentation(self, 0.0)!  }
     var test:Data   { return UIImageJPEGRepresentation(self, -0.3)!  }
    
}

