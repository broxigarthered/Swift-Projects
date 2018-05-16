//
//  ViewController.swift
//  Adi's Wardrobe Organizer
//
//  Created by Nikolay on 4/19/16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

import UIKit

class WardrobeMainController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var takePhotoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.takePhotoButton.alpha = 0
      
            UIView.animate(withDuration: 1.0, delay: 0.4, options: [], animations:
                {
                    self.takePhotoButton.alpha = 1.0
                    
                }, completion: nil)
        
    }


    @IBAction func takePhoto(_ sender: AnyObject) {
        
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            
            // present the view controller to the user (pokazvame prosto tva library)
            self.present(imagePicker, animated: true, completion: nil)
        
        // todo
        // 1. Get the photo and present the view controller with the types of clothes
        // 2. when clicked set the photo in the tab, that is needed
        
    }
}

