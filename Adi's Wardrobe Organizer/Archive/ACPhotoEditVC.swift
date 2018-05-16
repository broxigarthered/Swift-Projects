//
//  ACPhotoEditVC.swift
//  Adi's Wardrobe Organizer
//
//  Created by Nikolay on 1/19/17.
//  Copyright © 2017 Nikolay. All rights reserved.
//

import UIKit

class ACPhotoEditVC: UIViewController {
    @IBOutlet weak var image: UIImageView!
    var imageToSet: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.image.image = imageToSet
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
