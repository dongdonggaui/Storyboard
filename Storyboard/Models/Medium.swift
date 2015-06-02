//
//  Medium.swift
//  
//
//  Created by huangluyang on 15/6/2.
//
//

import Foundation
import CoreData

class Medium: NSManagedObject {

    @NSManaged var type: NSNumber
    @NSManaged var title: String
    @NSManaged var time: NSDate
    @NSManaged var mediumData: NSData
    @NSManaged var mediumPath: String
    @NSManaged var album: NSManagedObject

}
