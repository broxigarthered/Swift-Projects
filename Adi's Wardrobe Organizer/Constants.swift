//
//  Constants.swift
//  Adi's Wardrobe Organizer
//
//  Created by Adelina Dutskinova on 2/2/17.
//  Copyright © 2017 Nikolay. All rights reserved.
//

import Foundation


struct Constants {
    
    //MARK: Global
    static let defaults = UserDefaults.standard
    
    static let PHOTOSADDCOLLECTIONCELLHEIGHT = 234.0
    static let PHOTOSADDCOLLECTIONCELLWIDTH = 268.0
    
    // MARK: CollectionController
    static let collectionControllerSelectedCellHeight: CGFloat = 280.0
    static let collectionControllerDeselectedCellHeight: CGFloat = 150.0
    
    static let collectionControllerCollectionTypes: [String] = ["Outwear", "Blazers", "Dresses", "Jumpsuits", "Tops", "Trousers", "Jeans", "Shorts", "Skirts", "Knitwear", "T-Shirts", "Sweatshirts", "Beachwear", "Gymwear", "Shoes", "Bags", "Accessories"]
    
    static let collectionControllerCollectionImages: [UIImage] = [#imageLiteral(resourceName: "outwear"), #imageLiteral(resourceName: "blazers"), #imageLiteral(resourceName: "dresses"), #imageLiteral(resourceName: "jumpsuits"), #imageLiteral(resourceName: "tops"), #imageLiteral(resourceName: "trousers"), #imageLiteral(resourceName: "jeans"), #imageLiteral(resourceName: "shorts"), #imageLiteral(resourceName: "skirts"), #imageLiteral(resourceName: "knitwear"), #imageLiteral(resourceName: "t-shirts"), #imageLiteral(resourceName: "sweatshirts"), #imageLiteral(resourceName: "beachwear"), #imageLiteral(resourceName: "gymwear"), #imageLiteral(resourceName: "shoes"), #imageLiteral(resourceName: "bags"), #imageLiteral(resourceName: "accessories")]
    
    static let collectionControllerNavigationTitles: [String] = ["Spring Collection", "Summer Collection", "Fall Collection", "Winter Collection"]
    
    static let collectionControllerNSUserDefaultsTitles: [String] = ["outwear", "blazers", "dresses", "jumpsuits", "tops", "trousers", "jeans", "shorts", "skirts", "knitwear", "tshirts", "sweatshirts", "beachwear", "gymwear", "shoes", "bags", "accessories"]
    
    // MARK: ClothesCollectionController
    static let clothesCollectionControllerSelectedCellHeight: CGFloat = 300.0
    static let clothesCollectionControllerDeselectedCellHeight: CGFloat = 150.0
}

		
