//
//  CombinationImageMO.swift
//  Adi's Wardrobe Organizer
//
//  Created by Nikolay on 6/5/16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

import UIKit
import CoreData

class CombinationImageMO: NSManagedObject {
    @NSManaged var image: Data?
    @NSManaged var combination: CombinationMO
}
