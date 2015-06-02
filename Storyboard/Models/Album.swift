//
//  Album.swift
//  
//
//  Created by huangluyang on 15/6/2.
//
//

import Foundation
import CoreData

class Album: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var date: NSDate
    @NSManaged var image: NSData
    @NSManaged var imagePath: String
    @NSManaged var tags: String
    @NSManaged var media: NSOrderedSet

}
