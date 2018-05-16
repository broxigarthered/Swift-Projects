
//  PopOverPhotoViewController.swift
//  Adi's Wardrobe Organizer
//
//  Created by Nikolay on 5/5/16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

import UIKit

protocol PopOverPhotoViewControllerDelegate
{
    func doNothing()
}

class PopOverPhotoViewController: UIViewController, UIImagePickerControllerDelegate,
UIPopoverPresentationControllerDelegate,
UINavigationControllerDelegate {
    
    var delegate: PopOverPhotoViewControllerDelegate?
    var currentImage: UIImageView!
    var hasClickedEitherButton: Bool! = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    override func viewWillDisappear(_ animated: Bool) {
        
            if((self.delegate) != nil)
            {
                delegate?.doNothing();
            }
    }
    
    
    @IBAction func choosePhotoFromLibrary(_ sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func takePhoto(_ sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.currentImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage

        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation



}
