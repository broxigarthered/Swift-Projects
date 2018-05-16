//
//  Manage.swift
//  Adi's Wardrobe Organizer
//
//  Created by Nikolay on 5/4/16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

import UIKit

protocol ManagePhotoControllerDelegate
{
    func changePhotoAtIndex(_ image: UIImage, index: Int)
}

protocol ManagePhotoControllerDeleteImage {
    func deleteImageAtIndex(_ index: Int)
}

class ManagePhotoController: UIViewController, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate, PopOverPhotoViewControllerDelegate {
    
    @IBOutlet weak var managePhotoImageView: UIImageView!
    
    var delegate: ManagePhotoControllerDelegate? = nil
    var mpcDeleteImageDelegate: ManagePhotoControllerDeleteImage? = nil
    
    var currentImage: UIImage!
    var arrayIndex: Int = 0
    
    var dbCurrentIndex: Int = 0
    let blurEffect = UIBlurEffect(style: .dark)
    var blurEffectView = UIVisualEffectView()
    
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        managePhotoImageView.image = currentImage
        
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0
        
        self.view.insertSubview(blurEffectView, belowSubview: button)
        //self.view.addSubview(blurEffectView)
    }
    
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil{
            if ((self.delegate) != nil) {
                delegate?.changePhotoAtIndex(managePhotoImageView.image!, index: self.arrayIndex)
            }
        }
    }
 
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changePhoto"{
            
            let destinationController = segue.destination as! PopOverPhotoViewController
            
            destinationController.currentImage = self.managePhotoImageView
            destinationController.delegate = self
            destinationController.modalPresentationStyle = .popover
            destinationController.preferredContentSize = CGSize(width: 150, height: 120)
            
            if let popoverMenu = destinationController.popoverPresentationController
            {
                popoverMenu.permittedArrowDirections = .down// shiet
                popoverMenu.delegate = self
                popoverMenu.sourceView = sender as! UIButton
                popoverMenu.sourceRect = ((sender as AnyObject).bounds)!
            }
            
            
            blurEffectView.alpha = 0.8
        }
    }
    
    func doNothing(){
        self.blurEffectView.alpha = 0
    }
    
    @IBAction func openAlertView(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Edit", message: "Remove or add to collection", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { (action: UIAlertAction) in
            self.deleteImage()
        }

        let addPhotoToCombinationAction = UIAlertAction(title: "Add to combination", style: .default) { (action: UIAlertAction) in
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        alertController.addAction(addPhotoToCombinationAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteImage() {
        self.mpcDeleteImageDelegate?.deleteImageAtIndex(self.dbCurrentIndex)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .none
    }
    
    
    
}
