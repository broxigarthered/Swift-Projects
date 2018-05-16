//
//  PhotosAddCombination.swift
//  Adi's Wardrobe Organizer
//
//  Created by Nikolay on 5/24/16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

import UIKit

protocol ImagesToDeleteDelegate {
    func deleteImagesAtIndexes(indexes: [Int], largeImageToDelete: Data)
}

class PhotosAddCombination: UICollectionViewController{
    @IBOutlet weak var viewButton: UIButton!
    
    // toq delegat zaedno s methoda 6te gi viknem kogato se cukne delete
    var delegate: ImagesToDeleteDelegate!
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 10, left: 20.0, bottom: 10.0, right: 20.0)
    fileprivate var blurEffect: UIBlurEffect!
    fileprivate var blurEffectView: UIVisualEffectView!
    fileprivate var selectedCellIndexPath: IndexPath?
    
    var currentCombinationImages: [Data] = []
    var imagesToSet: NSArray!
    var largeImagesToSet: NSArray!
    
    var itemsToDeleteIndexes: [Int] = []
    // removing the observer when done
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // this was causing the problem uicollectionview cell not to get clicked when tapped
        //self.hideKeyboardWhenTappedAround()
        
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.isUserInteractionEnabled = true
        self.collectionView?.allowsSelection = true
        self.collectionView?.allowsMultipleSelection = false
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CombinationsImageCell
        
        cell.imageView.contentMode = .scaleAspectFill
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        
        //TODO: reduce the image size
        let imageToSet = UIImage(data: (self.largeImagesToSet[indexPath.row] as! Data))?.lowestQualityJPEGNSData
        //let nerfedQuality = UIImage(data: imageToSet)?.lowestQualityJPEGNSData
       
        let nerfedQualityImageToSet = self.resizeImage(image: UIImage(data: imageToSet!)!, targetSize: cell.bounds.size)
        
        print((imageToSet?.count)! / 1024)
        
        cell.imageView.image = nerfedQualityImageToSet
        
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
            
            // set blur effect
            self.blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
            self.blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = cell.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            //cell.addSubview(blurEffectView)
            cell.deleteButton.isHidden = false
            cell.viewButton.isHidden = false

            cell.imageView.addSubview(blurEffectView)
            
            UIView.animate(withDuration: 0.4, animations: {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
            })
            
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.largeImagesToSet != nil {
            if self.largeImagesToSet.count > 0 {
                return self.largeImagesToSet.count
            }
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewPhoto" {
            
            let destinationViewController = segue.destination as! ACPhotoEditVC
            
            let selectedCell = self.collectionView?.cellForItem(at: (self.collectionView?.indexPathsForSelectedItems?[0])!) as! CombinationsImageCell
            
            print(self.selectedCellIndexPath?.row)
            
            let imageToSet = self.largeImagesToSet[(self.collectionView?.indexPathsForSelectedItems?[0].item)!] as! Data
            
             destinationViewController.imageToSet = UIImage(data: imageToSet)
        }
        
    }
    
    //MARK: Custom Methods
    func actOnSpecialNotification(){
        self.collectionView?.reloadData()
    }
        
    func transferLargeImages(largeImages: NSArray){
        self.largeImagesToSet = largeImages
    }
    
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
    
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
//        let currentIndex = selectedCellIndexPath?.item
        let indexOfDeletedItem = self.collectionView?.indexPathsForSelectedItems?[0].item
        let indexPathOfDeletedItem = self.collectionView?.indexPathsForSelectedItems?[0]
        self.itemsToDeleteIndexes.append(indexOfDeletedItem!)
        
        ////get the image
        let largeImageToDelete = largeImagesToSet[indexOfDeletedItem!] as? Data
        
        //delete images from imagesToSet and largeImagesToSet
        let mutableLargeImages = self.largeImagesToSet.mutableCopy() as! NSMutableArray
        mutableLargeImages.removeObject(at: indexOfDeletedItem!)
        self.largeImagesToSet = mutableLargeImages as? NSArray
        
        //delete the cell of the collectionView
        self.collectionView?.deleteItems(at: [indexPathOfDeletedItem!])
        self.collectionView?.reloadData()
        
        self.delegate.deleteImagesAtIndexes(indexes: self.itemsToDeleteIndexes, largeImageToDelete: largeImageToDelete!)
        
        self.itemsToDeleteIndexes = []
    }
}
