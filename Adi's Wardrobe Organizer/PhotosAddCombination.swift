//
//  PhotosAddCombination.swift
//  Adi's Wardrobe Organizer
//
//  Created by Nikolay on 5/24/16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

import UIKit
import SDWebImage

protocol ImagesToDeleteDelegate {
    func deleteImagesAtIndexes(indexes: [Int], imageName: String)
    func addNewImages()
}

class PhotosAddCombination: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var viewButton: UIButton!
    
    // toq delegat zaedno s methoda 6te gi viknem kogato se cukne delete
    var delegate: ImagesToDeleteDelegate!
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 5, left: 5.0, bottom: 3, right: 3)
    fileprivate var blurEffect: UIBlurEffect!
    fileprivate var blurEffectView: UIVisualEffectView!
    fileprivate var selectedCellIndexPath: IndexPath?
    
    var currentCombinationImages: [Data] = []
    var largeImages: NSArray!
    var smallImages: NSArray!
    var imagesNames: [String] = []
    
    var itemsToDeleteIndexes: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        //var width = UIScreen.main.bounds.width
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
      
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 2
        collectionView!.collectionViewLayout = layout
        
        // this was causing the problem uicollectionview cell not to get clicked when tapped
        //self.hideKeyboardWhenTappedAround()
        
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.isUserInteractionEnabled = true
        self.collectionView?.allowsSelection = true
        self.collectionView?.allowsMultipleSelection = false

    }
    
    override func viewWillAppear(_ animated: Bool) {
        //cache the images when the view appears
        
        let dbManager = ImageSaveManager.sharedInstance
        DispatchQueue.main.async {
            for imageName in self.imagesNames{
                dbManager.cacheImage(imageName: imageName)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CombinationsImageCell

        cell.imageView.contentMode = .scaleAspectFill
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        
        if indexPath.row == 0 {
            cell.imageView.image = UIImage(named: "folder-plus")
            cell.viewButton.isEnabled = false
            cell.deleteButton.isEnabled = false
            cell.viewButton.isHidden = true
            cell.deleteButton.isHidden = true
        }
        else{
            let imageName = self.imagesNames[indexPath.row-1]
            
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
            
            let pathsNSURL = URL(string: paths)
            
            if !SDWebImageManager.shared().cachedImageExists(for: pathsNSURL) {
                let imageToSet = UIImage(contentsOfFile: paths)
                SDWebImageManager.shared().saveImage(toCache: imageToSet, for: URL(string: paths))
            }
            
            cell.imageView?.sd_setImage(with: pathsNSURL)
        }
        
        // Remove the blur effect from the cells that are being loaded.
        for subview in cell.imageView.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
        
        cell.deleteButton.isHidden = true
        cell.viewButton.isHidden = true
        
        selectedCellIndexPath = nil
        
        return cell
    }
    
    // fixing the cells size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let mainScreenBounds = UIScreen.main.bounds
        
        return CGSize(width: mainScreenBounds.width/3-2, height: mainScreenBounds.height/5-2);
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CombinationsImageCell
        
        //deselection of all other cells except the one currently clicked
        var indexPathsForVisiableCells = collectionView.indexPathsForVisibleItems
        let indexOfCurrentCell = indexPathsForVisiableCells.index(of: indexPath)
        indexPathsForVisiableCells.remove(at: indexOfCurrentCell!)
        
        for iP in indexPathsForVisiableCells {
            collectionView.deselectItem(at: iP, animated: true)
            let deselectedCell = collectionView.cellForItem(at: iP) as! CombinationsImageCell
            
            //remove the blur effect for every deselected cell
            if self.blurEffectView != nil {
                for subview in deselectedCell.imageView.subviews {
                    if subview is UIVisualEffectView {
                        subview.removeFromSuperview()
                    }
                }
            }
            
            deselectedCell.deleteButton.isHidden = true
            deselectedCell.viewButton.isHidden = true
        }
        
        // remove the blur effect from the currently selected cell
        if selectedCellIndexPath != nil && selectedCellIndexPath == indexPath {
            selectedCellIndexPath = nil
            
            // remove blur effect
            if self.blurEffectView != nil {
                for subview in cell.imageView.subviews {
                    if subview is UIVisualEffectView {
                        subview.removeFromSuperview()
                    }
                }
            }
            
            cell.deleteButton.isHidden = true
            cell.viewButton.isHidden = true
        } else {
            selectedCellIndexPath = indexPath
            //cell.isSelected = true
            
            //check if the clicked cell is the first one, if it is no blur or buttons are showed
            // the delegate is called to save images
            if(indexPath.row == 0){
                self.delegate.addNewImages()
            }
            else{
                // set blur effect
                self.blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
                self.blurEffectView = UIVisualEffectView(effect: blurEffect)
                self.blurEffectView.alpha = 1
                blurEffectView.frame = cell.bounds
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                //cell.addSubview(blurEffectView)
                cell.deleteButton.isHidden = false
                cell.viewButton.isHidden = false
                
                cell.imageView.addSubview(blurEffectView)
            }
            
            UIView.animate(withDuration: 0.4, animations: {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
            })
            
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.imagesNames.count > 0 {
            return self.imagesNames.count+1
        }
        
        return 1
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewPhoto" {
            
            let destinationViewController = segue.destination as! ACPhotoEditVC
            
            let selectedCell = self.collectionView?.cellForItem(at: (self.collectionView?.indexPathsForSelectedItems?[0])!) as! CombinationsImageCell
            
            print(self.selectedCellIndexPath?.row)
            
            let dbImageSaverInsntance = ImageSaveManager.sharedInstance
            let indexOfSelectedItem = self.collectionView?.indexPathsForSelectedItems?[0].item
            let imageName = self.imagesNames[indexOfSelectedItem!]
            let imageToSet = dbImageSaverInsntance.getImage(indexOfSelectedItem!, imageName)
            
            
            destinationViewController.imageToSet = imageToSet
        }
        
    }
    
    //MARK: Custom Methods
    func actOnSpecialNotification(){
        self.collectionView?.reloadData()
    }
    
    func transferSmallImages(smallImages: NSArray){
        self.smallImages = smallImages
    }
    
    func transferBigImages(bigImages: NSArray) {
        self.largeImages = bigImages
    }
    
    func transferImagesNames(images: [String]){
        self.imagesNames = images
    }
    
    func getImage(_ atIndex: Int) -> UIImage {
        let imageName = self.imagesNames[atIndex]
        
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        
        let pathsNSURL = URL(string: paths)
        
        if !SDWebImageManager.shared().cachedImageExists(for: pathsNSURL) {
            let imageToSet = UIImage(contentsOfFile: paths)
            SDWebImageManager.shared().saveImage(toCache: imageToSet, for: URL(string: paths))
        }
        
        let imageViewToReturn = UIImage(contentsOfFile: paths)
        
        return imageViewToReturn!
    }
    
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        //        let currentIndex = selectedCellIndexPath?.item
        let indexOfDeletedItem = self.collectionView?.indexPathsForSelectedItems?[0].item
        let indexPathOfDeletedItem = self.collectionView?.indexPathsForSelectedItems?[0]
        self.itemsToDeleteIndexes.append(indexOfDeletedItem!)
        let nameOfDeletedImage = self.imagesNames[indexOfDeletedItem!]
        
        self.imagesNames.remove(at: indexOfDeletedItem!)
        self.collectionView?.deleteItems(at: [indexPathOfDeletedItem!])
        
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
        
        self.delegate.deleteImagesAtIndexes(indexes: self.itemsToDeleteIndexes, imageName: nameOfDeletedImage)
        
        self.itemsToDeleteIndexes = []
    }
}
