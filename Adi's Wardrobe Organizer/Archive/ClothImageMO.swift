//
//  ClothImage+CoreDataProperties.swift
//  Adi's Wardrobe Organizer
//
//  Created by Nikolay on 5/15/16.
//  Copyright © 2016 Nikolay. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import Foundation
import CoreData

class ClothImageMO : NSManagedObject {

    @NSManaged var image: Data?
    @NSManaged var cloth: ClothMO?

}
