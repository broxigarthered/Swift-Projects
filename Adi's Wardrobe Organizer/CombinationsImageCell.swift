//
//  CombinationsImageCell.swift
//  Adi's Wardrobe Organizer
//
//  Created by Nikolay on 5/24/16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

import UIKit

class CombinationsImageCell: UICollectionViewCell {

    let themeColor = UIColor(red: 0.01, green: 0.41, blue: 0.22, alpha: 1.0)
    
    @IBOutlet weak var viewButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
  }
