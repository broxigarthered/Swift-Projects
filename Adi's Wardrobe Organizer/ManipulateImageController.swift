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
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var browseCollectionButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet var backgroundImage: UIImageView!
    
    @IBOutlet weak var buttonStackView: UIStackView!
    
    var hasChosenImage: Bool = false
    var clothImage: UIImageView!
    var currentDefaultImage: UIImage!
    
    var cloth: ClothMO!
    var clothImageMO: ClothImageMO!
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.buttonStackView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        self.messageLabel.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        
        // checks if should move to previous controller
        let shouldChange = Constants.defaults.bool(forKey: "shouldMoveToPreviousController")
        if shouldChange {
            Constants.defaults.set(false, forKey: "shouldMoveToPreviousController")
            self.performSegue(withIdentifier: "unwindToHomeScreen", sender: nil)   
        }
    }
    
    // Here we create the enalrgement effect of the text and the buttons
    override func viewDidAppear(_ animated: Bool) {
        
        UIView.animate(withDuration: 0.7) {
            self.buttonStackView.transform = CGAffineTransform(scaleX: 1,y: 1)
            self.messageLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cameraImageToSet = UIImage(named: "camera")?.maskWithColor(color: .white)
        let closeImageToSet = UIImage(named: "close")?.maskWithColor(color: .white)
        let collectionImageToSet = UIImage(named: "collection2")?.maskWithColor(color: .white)
        self.takePhotoButton.setImage(cameraImageToSet, for: .normal)
        self.browseCollectionButton.setImage(collectionImageToSet, for: .normal)
        self.closeButton.setImage(closeImageToSet, for: .normal)
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        // self.backgroundImage.addSubview(blurEffectView)
        
        self.view.insertSubview(blurEffectView, aboveSubview: backgroundImage)
        
        backgroundImage.image = currentDefaultImage
    }
    
    // Once image is picked, calls this function to save the new image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // MARK: Cut image once
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let temporalImage = image.mediumQualityJPEGNSData
        
        let resizedImage = UIImage(data: temporalImage)
        //let resizedImage = UIImage(data: temporalImage)?.resizeWith(percentage: 0.35)
        //print((UIImagePNGRepresentation(resizedImage!)?.count)!/1024)
        
        saveData(resizedImage!)
        
        backgroundImage.image = UIImage(data: UIImagePNGRepresentation(resizedImage!)!)
        
        Constants.defaults.set(true, forKey: "shouldMoveToPreviousController")
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
        
        let currentSeason = Constants.defaults.string(forKey: "currentSeason")
        let currentClothType = Constants.defaults.string(forKey: "currentClothType")
        let dbContext = ImageSaveManager.sharedInstance
        
        
        // 1. moc = managed object context
        if let moc = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
            
            // 2. inserting and modifying the data
            cloth = NSEntityDescription.insertNewObject(forEntityName: "Cloth", into: moc) as! ClothMO
            
            cloth.isSelected = false
            cloth.clothType = currentClothType!
            cloth.seasonName = currentSeason!
            
            // generate new image name and save it
            let imageName = dbContext.generateImageName()
            dbContext.saveImageDocumentDirectory(image: image, imageName: imageName)
            cloth.clothImageName = imageName
            
            print("IMAGE SIZE \((UIImagePNGRepresentation(image)?.count)!/1024)")
            
            
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
