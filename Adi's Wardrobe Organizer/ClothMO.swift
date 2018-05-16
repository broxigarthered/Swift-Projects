//
//  ClothMO.swift
//  Adi's Wardrobe Organizer
//
//  Created by Nikolay on 5/14/16.
//  Copyright © 2016 Nikolay. All rights reserved.

import Foundation
import UIKit
import CoreData

class ClothMO: NSManagedObject {
    @NSManaged var image: Data
    @NSManaged var seasonName: String
    @NSManaged var clothType: String
    @NSManaged var imageTest: ClothImageMO
    @NSManaged var isSelected: Bool
    @NSManaged var clothImageName: String
}
