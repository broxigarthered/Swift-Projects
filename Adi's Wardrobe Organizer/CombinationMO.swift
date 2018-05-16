//
//  CombinationMO.swift
//  Adi's Wardrobe Organizer
//
//  Created by Nikolay on 6/3/16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class CombinationMO: NSManagedObject {
    @NSManaged var rating: Double
    @NSManaged var tags: [String]
    @NSManaged var season: String
    @NSManaged var combinationImages: [String]
    
    // todo maybe set an array or set for the images, or I will just call it as value of attribute *relation
}
