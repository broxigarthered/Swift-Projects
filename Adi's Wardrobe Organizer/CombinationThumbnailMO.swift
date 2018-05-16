//
//  CombinationThumbnailImageMO.swift
//  Adi's Wardrobe Organizer
//
//  Created by Nikolay on 1/11/17.
//  Copyright © 2017 Nikolay. All rights reserved.
//

import UIKit
import CoreData

class CombinationThumbnailMO: NSManagedObject {
    @NSManaged var thumbnail: Data?
    @NSManaged var combination: CombinationMO
}
