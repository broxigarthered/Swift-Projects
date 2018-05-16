//
//  initTableViewController.swift
//  Adi's Wardrobe Organizer
//
//  Created by Nikolay on 4/22/16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

import UIKit

class initTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let seasonViewController = SeasonsTableViewController()
        presentViewController(seasonViewController, animated: true, completion: nil)
    }

}
