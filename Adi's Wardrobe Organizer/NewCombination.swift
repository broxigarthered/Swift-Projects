
//
//  NewCombination.swift
//  Adi's Wardrobe Organizer
//
//  Created by Nikolay on 5/31/16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

import UIKit
import CoreData
import YangMingShan
import SDWebImage

// notification
let mySpecialNotificationKey = "ThunderseekersGroup.addingPhotos.notificationKey"
let tagsNotificatorKey = "TagsNotificationKey"

class NewCombination: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate, YMSPhotoPickerViewControllerDelegate, ImagesToDeleteOrAddDelegate
{
    fileprivate var photosAddCombinationViewController: PhotosAddCombination!
    fileprivate var tagsTableViewController: TagsTableViewController!
    
    var currentCombinationImages: [Data] = []
    var TESTCOMBINAITONIMAGES: [Data] = []
    var currentCOMBINATIONSTRINGS: [String] = []
    var namesOfRemovedImages: [String] = []
    
    var combinationNewImages:[Data] = []
    
    var imagesToDelete: [Int] = []
    
    var largeImageToDeleteData: [Data] = []
    
    @IBOutlet weak var addTagButton: UIButton!
    @IBOutlet weak var newTagTextField: UITextField!
    @IBOutlet weak var starRating: CosmosView!
    
    var combination: CombinationMO!
    var combinationImage: CombinationImageMO!
    var combinationThumbnail: CombinationThumbnailMO!
    var currentCombinationToModify: CombinationMO!
    
    let defaults = UserDefaults.standard
    
    let pickerViewController = YMSPhotoPickerViewController.init()
    var tags: [String] = []
    var clothesFromCollections: [ClothMO] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        // Fixing the image picker
        pickerViewController.numberOfPhotoToSelect = 10
        
        let customColor = UIColor.init(red: 64.0/255.0, green: 0.0, blue: 144.0/255.0, alpha: 1.0)
        let customCameraColor = UIColor.init(red: 86.0/255.0, green: 1.0/255.0, blue: 236.0/255.0, alpha: 1.0)
        
        pickerViewController.theme.titleLabelTextColor = UIColor.white
        pickerViewController.theme.navigationBarBackgroundColor = customColor
        pickerViewController.theme.tintColor = UIColor.white
        pickerViewController.theme.orderTintColor = customCameraColor
        pickerViewController.theme.cameraVeilColor = customCameraColor
        pickerViewController.theme.cameraIconColor = UIColor.white
        pickerViewController.theme.statusBarStyle = .lightContent
        
        //self.yms_presentCustomAlbumPhotoView(pickerViewController, delegate: self)
        
        // have to do with segue in order to send the combination..
        
        let shouldManageCombination = defaults.bool(forKey: "shouldLoadCombination")
        
        // check if the current combination is in managed mode, if it is get the images from the combination
        if shouldManageCombination {
            self.currentCOMBINATIONSTRINGS = self.currentCombinationToModify.combinationImages
            
            self.starRating.rating = currentCombinationToModify.rating
            self.transferImagesToPhotosCollection()
        }
        else{
            starRating.rating = 0
        }
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func saveData(_ sender: AnyObject) {
        let defaults = UserDefaults.standard
        let combinationImagesCountReal = self.currentCOMBINATIONSTRINGS.count
        
        // leave the uniqe tags in the tags array
        // in the method (validateFields) check its explicity by also checking whether the tags count is more than 3
        
        self.tags = self.tagsTableViewController.getTags()
        let tagsCount = self.tags.count
        let shouldProceed = validateFields(combinationImagesCountReal, starRating, tagsCount)
        
        if shouldProceed {
            // todo just modify the current item instead of inserting a new one it from the base
            let shouldManageCurrentCombination = defaults.bool(forKey: "shouldLoadCombination")
            
            // modify the current object
            if shouldManageCurrentCombination {

                var fetchResultController: NSFetchedResultsController<NSFetchRequestResult>!
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Combination")
                let sortDescriptor = NSSortDescriptor(key: "rating", ascending: true)
                
                fetchRequest.sortDescriptors = [sortDescriptor]
                
                if let moc = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext{
                    
                    fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
                    
                    fetchResultController.delegate = self
                    
                    var combinationsToManage: [CombinationMO]!
                    
                    do{
                        try fetchResultController.performFetch()
                        combinationsToManage = fetchResultController.fetchedObjects as! [CombinationMO]
                    } catch {
                        print(error)
                    }
                    
                    currentCombinationToModify.rating = self.starRating.rating
                    currentCombinationToModify.tags = tags
                    currentCombinationToModify.combinationImages = self.currentCOMBINATIONSTRINGS

                    let rowToModify = defaults.integer(forKey: "currentRowToModify")
                   
                        combinationsToManage[rowToModify] = self.currentCombinationToModify
                        do {
                            try moc.save()
                        } catch {
                            print(error)
                            return
                        }
                }
            } else {
                // save the new object
                if let moc = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext{
                    
                    combination = NSEntityDescription.insertNewObject(forEntityName: "Combination", into: moc) as! CombinationMO
                    
                    combination.rating = starRating.rating
                    //self.tags = UserDefaults.standard.object(forKey: "combinationTags") as! [String]
                    
                    combination.tags = self.tags
                    let seasonToSet = UserDefaults.standard.string(forKey: "currentSeason")
                    
                    combination.season = seasonToSet!
                    combination.combinationImages = self.currentCOMBINATIONSTRINGS

                    // save
                        do {
                            try moc.save()
                        } catch {
                            print(error)
                            return
                        }
                }
            }
            
            // remove the images from the directory
            if self.namesOfRemovedImages.count > 0 {
                let dbManager = ImageSaveManager.sharedInstance
                
                for imageName in self.namesOfRemovedImages {
                    dbManager.removeImage(itemName: imageName)
                }
            }
            
            navigationController?.popViewController(animated: true)
        }
    }
    
    func addNewImages(){
        let optionMenu = UIAlertController(title: "Upload a photo", message: "Chose from where", preferredStyle: .actionSheet)
        
//        optionMenu.popoverPresentationController?.sourceView = self.view
//        optionMenu.popoverPresentationController?.sourceRect = sender.bounds
        // this is the center of the screen currently but it can be any point in the view
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        optionMenu.addAction(cancelAction)
        
        // pick image from collection
        let pickImageFromLibrary = UIAlertAction(title: "Browse Photo Library", style: .default, handler: { (action: UIAlertAction!) in
            
            // MARK: Call the advanced album photoview
            
            self.yms_presentCustomAlbumPhotoView(self.pickerViewController, delegate: self)
        })
        
        optionMenu.addAction(pickImageFromLibrary)
        
        let pickImageFromCamera = UIAlertAction(title: "Take a photo", style: .default, handler: {
            (action: UIAlertAction!) in
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            
            self.present(imagePicker, animated: true, completion: nil)
        })
        
        optionMenu.addAction(pickImageFromCamera)
        
        let pickImageFromCollection = UIAlertAction(title: "Browse Cloth Collection", style: .default, handler: { (action: UIAlertAction!) in
            
            
            //MARK: tell the collection view controller that it is opened through new combination
            self.defaults.set(true, forKey: "sholdOpenNewCombination")
            
            //MARK: presetnt the cloth collection view controller
            self.performSegue(withIdentifier: "openClothCollection", sender: nil)
            
        })
        
        // optionMenu.addAction(pickImageFromCollection)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func addTag(_ sender: AnyObject) {
        if self.newTagTextField.text?.isEmpty == true{
            
            let optionMenu = UIAlertController(title: "Error", message: "Tag cannot be empty", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            optionMenu.addAction(cancelAction)
            
            self.present(optionMenu, animated: true, completion: nil)
        } else {
            if self.newTagTextField.text?.contains(" ") == true{
                
                let optionMenu = UIAlertController(title: "Error", message: "Tag cannot contain white space", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                optionMenu.addAction(cancelAction)
                
                self.present(optionMenu, animated: true, completion: nil)
            } else {
                tags.append(newTagTextField.text!)
                print(tags)
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let userDefaults = UserDefaults.standard
        let shouldLoadCombination = userDefaults.bool(forKey: "shouldLoadCombination")
        
        if segue.source.isEqual(CombinationsController.self)  && shouldLoadCombination == true {
        }
        
        if segue.identifier == "openClothCollection"  {
            //let destinationViewController = segue.destination as! CollectionController
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
        
        if segue.identifier == "testPhotosContainer"{
            if let destinationViewController = segue.destination as? PhotosAddCombination{
                
                destinationViewController.delegate = self
                self.photosAddCombinationViewController = destinationViewController
            }
        }
        
        if segue.identifier == "tagsSegue"{
            if let destinationViewController = segue.destination as? TagsTableViewController{
                
                self.tagsTableViewController = destinationViewController
                
                let defaults = UserDefaults.standard
                let shouldLoadTags = defaults.bool(forKey: "shouldLoadCombination")
                
                if shouldLoadTags {
                    self.tagsTableViewController.tagsToModify = self.currentCombinationToModify.tags
                }
            }
        }
    }
    
    // MARK: Observer pattern -> NotificationCenter method
    func notifyTagsShouldGetSaved()
    {
        NotificationCenter.default.post(name: Notification.Name(rawValue: tagsNotificatorKey), object: self)
    }
    
    // MARK: Additional methods
    func validateFields(_ combinationImagesCount: Int,  _ cosmosView: CosmosView, _ tagsCount: Int) -> Bool{
        
        if (combinationImagesCount == 0 || cosmosView.rating == 0 || tagsCount == 0) {
            
            let warningMenu = UIAlertController(title: "Error", message: "We can't proceed because one of the fields is blank or there are no images set. Please note that all fields are required", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            warningMenu.addAction(cancelAction)
            self.present(warningMenu, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
    
    // MARK: Custom Album Browser Methods
    func photoPickerViewControllerDidReceivePhotoAlbumAccessDenied(_ picker: YMSPhotoPickerViewController!) {
        let alertController = UIAlertController.init(title: "Allow photo album access?", message: "Need your permission to access photo albumbs", preferredStyle: .alert)
        let dismissAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction.init(title: "Settings", style: .default) { (action) in
            UIApplication.shared.openURL(URL.init(string: UIApplicationOpenSettingsURLString)!)
        }
        alertController.addAction(dismissAction)
        alertController.addAction(settingsAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func photoPickerViewControllerDidReceiveCameraAccessDenied(_ picker: YMSPhotoPickerViewController!) {
        let alertController = UIAlertController.init(title: "Allow camera album access?", message: "Need your permission to take a photo", preferredStyle: .alert)
        let dismissAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction.init(title: "Settings", style: .default) { (action) in
            UIApplication.shared.openURL(URL.init(string: UIApplicationOpenSettingsURLString)!)
        }
        alertController.addAction(dismissAction)
        alertController.addAction(settingsAction)
        
        // The access denied of camera is always happened on picker, present alert on it to follow the view hierarchy
        picker.present(alertController, animated: true, completion: nil)
    }
    
    // Gets called after the user has finished picking images
    func photoPickerViewController(_ picker: YMSPhotoPickerViewController!, didFinishPickingImages photoAssets: [PHAsset]!) {
        // Remember images you get here is PHAsset array, you need to implement PHImageManager to get UIImage data by yourself
        picker.dismiss(animated: true) {
            let imageManager = PHImageManager.init()
            let options = PHImageRequestOptions.init()
            options.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
            options.resizeMode = .exact
            options.isSynchronous = true
            
            let mutableImages: NSMutableArray! = []
            let lowQualityMutableImages: NSMutableArray! = []
            
            for asset: PHAsset in photoAssets
            {
                imageManager.requestImageData(for: asset, options: options, resultHandler: { (image, info, random, random1) in
                    
                    let dbManager = ImageSaveManager.sharedInstance
                    let imageName = dbManager.generateImageName()
                    dbManager.saveImageDocumentDirectory(image: UIImage(data: image!)!, imageName: imageName)
                    self.currentCOMBINATIONSTRINGS.append(imageName)
                    dbManager.cacheImage(imageName: imageName)
                })
            }
            
            self.transferImagesToPhotosCollection()
        }
    }
    
  
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        var temporalImage = image.mediumQualityJPEGNSData
        
        if temporalImage.count/1024 > 400 {
            let customImage = UIImage(data: temporalImage)
            temporalImage = customImage!.lowQualityJPEGNSData
        }
        
        let dbManager = ImageSaveManager.sharedInstance
        let imageName = dbManager.generateImageName()
        dbManager.saveImageDocumentDirectory(image: image, imageName: imageName)
        self.currentCOMBINATIONSTRINGS.append(imageName)
        dbManager.cacheImage(imageName: imageName)
        
        self.transferImagesToPhotosCollection()
        dismiss(animated: true, completion: nil)
    }
    
    func appendImagesFromCameraOrLibrary(shouldManageCombination: Bool, temporalImage: Data) {
        if shouldManageCombination{
            if(!self.currentCombinationImages.contains(temporalImage as Data) && !self.combinationNewImages.contains(temporalImage as Data))
            {
                self.combinationNewImages.append(temporalImage as Data)
            }
        }
        
        if(!self.currentCombinationImages.contains(temporalImage as Data))
        {
            self.currentCombinationImages.append(temporalImage as Data)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let shouldOpenImagesFromCollection = self.defaults.bool(forKey: "sholdOpenNewCombination")
        
        if shouldOpenImagesFromCollection {
            
            if defaults.bool(forKey: "newImageAdded") {
                //MARK: Photos will be added here from the collections
                defaults.set(false, forKey: "newImageAdded")
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cloth")
                let sortDescriptor = NSSortDescriptor(key: "clothType", ascending: true)
                fetchRequest.sortDescriptors = [sortDescriptor]
                fetchRequest.predicate = NSPredicate(format: "isSelected == %@", NSNumber(booleanLiteral: true))
                
                if let moc = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext{
                    
                    let fetchResultController: NSFetchedResultsController<NSFetchRequestResult>!
                    
                    fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
                    fetchResultController.delegate = self
                    
                    do{
                        try fetchResultController.performFetch()
                        self.clothesFromCollections = fetchResultController.fetchedObjects as! [ClothMO]
                    } catch {
                        print(error)
                    }
                }
                
                let shouldManageCombination = self.defaults.bool(forKey: "shouldLoadCombination")
                
                for cloth in self.clothesFromCollections {
                    
                    let imageName = cloth.clothImageName
                    let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
                    let pathsNSURL = URL(string: paths)
                    
                    let imageToSet = UIImage(contentsOfFile: paths)
                    if !SDWebImageManager.shared().cachedImageExists(for: pathsNSURL) {
                        SDWebImageManager.shared().saveImage(toCache: imageToSet, for: URL(string: paths))
                    }

                    
                    if cloth.isSelected {
                        
                        let temporalImage = imageToSet
                        let nerfedQualityImage = UIImagePNGRepresentation((imageToSet?.resizeWith(percentage: 0.9))!)!
                        let lowQualityImage = UIImage(data: nerfedQualityImage)?.lowQualityJPEGNSData
                        
                        //TODO: Sort reduce the image size properly
                        
                        print((lowQualityImage?.count)!/1024)
                        
//                        if(!self.TESTCOMBINAITONIMAGES.contains(UIImagePNGRepresentation(temporalImage!)!)){
//                            self.TESTCOMBINAITONIMAGES.append(UIImagePNGRepresentation(temporalImage!)!)
//                            self.currentCombinationImages.append(lowQualityImage! as Data)
                        let dbManager = ImageSaveManager.sharedInstance
                        let imageName = dbManager.generateImageName()
                        dbManager.saveImageDocumentDirectory(image: UIImage(data: nerfedQualityImage)!, imageName: imageName)
                        self.currentCOMBINATIONSTRINGS.append(imageName)
                        dbManager.cacheImage(imageName: imageName)
                     
                        cloth.isSelected = false
                    }
                }
                
                self.transferImagesToPhotosCollection()
            }
        }
        
        self.defaults.set(false, forKey: "sholdOpenNewCombination")
    }
    
    func transferImagesToPhotosCollection (){
        self.photosAddCombinationViewController.transferImagesNames(images: self.currentCOMBINATIONSTRINGS)
        self.photosAddCombinationViewController.collectionView?.reloadData()
        
        self.photosAddCombinationViewController.collectionView?.reloadItems(at: (photosAddCombinationViewController.collectionView?.indexPathsForVisibleItems)!)
    }
    
    // MARK: Delegate for PhotoAddCombination
    func deleteImagesAtIndexes(indexes: [Int], imageName: String) {
        self.currentCOMBINATIONSTRINGS.remove(at: indexes[0])
        self.namesOfRemovedImages.append(imageName)
    }
}

