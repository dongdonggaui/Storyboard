//
//  StoryViewModel.swift
//  Storyboard
//
//  Created by huangluyang on 15/6/4.
//  Copyright (c) 2015年 HLY. All rights reserved.
//

import UIKit
import CoreData

enum StoryDisplayStyle : Int {
    
    case Timeline
    case Category
}

class StoryViewModel: RVMViewModel, NSFetchedResultsControllerDelegate {
    lazy private var _updatedContentSignal: RACSignal = RACSubject()
    var updatedContentSignal: RACSignal {
        return _updatedContentSignal
    }
    private var _model: Album
    var model: Album {
        return _model
    }
    var displayStyle: StoryDisplayStyle = .Timeline
    
    var managedObjectContext: NSManagedObjectContext {
        return ASHCoreDataStack.defaultStack().managedObjectContext
    }
    
    init(model: Album) {
        _model = model
        super.init()
        self.didBecomeActiveSignal.subscribeNext { (any) -> Void in
            self.fetchedResultsController.performFetch(nil)
        }
    }
    
    // MARK: - Public
    func numberOfSections() -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func cellIdentifierForIndexPath(indexPath: NSIndexPath) -> String {
        var identifier = "cell"
        switch self.displayStyle {
        case .Category:
            identifier = "CategoryCell"
        case .Timeline:
            var medium = self.mediumAtIndexPath(indexPath)
            if medium.type.integerValue == 0 {
                identifier = "ArticleCell"
            } else {
                identifier = "TimeLineCell"
            }
        }
        return identifier
    }
    
    func titleAtIndexPath(indexPath: NSIndexPath) -> String {
        var album = self.mediumAtIndexPath(indexPath)
        return album.title
    }
    
//    func imageAtIndexPath(indexPath: NSIndexPath) -> UIImage? {
//        var album = self.mediumAtIndexPath(indexPath)
//        return UIImage(data: album.image)
//    }
    
    func dateAtIndexPath(indexPath: NSIndexPath) -> NSDate {
        var album = self.mediumAtIndexPath(indexPath)
        return album.time
    }
    
    func deleteObjectAtIndexPath(indexPath: NSIndexPath) {
        var object: NSManagedObject = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        var context = self.fetchedResultsController.managedObjectContext
        context.deleteObject(object)
        
        var error: NSError? = nil
        if !context.save(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }
    
    // MARK: - Private
    func mediumAtIndexPath(indexPath: NSIndexPath) -> Medium {
        return self.fetchedResultsController.objectAtIndexPath(indexPath) as! Medium
    }
    
    // MARK: - Fetched results controller
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        (_updatedContentSignal as! RACSubject).sendNext("will")
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        var dic: Dictionary<String, AnyObject!> = Dictionary<String, AnyObject!>()
        dic["type"] = "sction"
        dic["section"] = NSNumber(integer: sectionIndex)
        switch type {
        case .Insert:
            dic["changeType"] = "insert"
        case .Delete:
            dic["changeType"] = "delete"
        default:
            return
        }
        (_updatedContentSignal as! RACSubject).sendNext(dic)
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        var dic: Dictionary<String, AnyObject!> = Dictionary<String, AnyObject!>()
        dic["type"] = "indexPath"
        dic["indexPath"] = indexPath
        dic["newIndexPath"] = newIndexPath
        switch type {
        case .Insert:
            dic["changeType"] = "insert"
        case .Delete:
            dic["changeType"] = "delete"
        case .Update:
            dic["changeType"] = "update"
        case .Move:
            dic["changeType"] = "move"
        default:
            return
        }
        (_updatedContentSignal as! RACSubject).sendNext(dic)
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        (_updatedContentSignal as! RACSubject).sendNext("did")
    }
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Medium", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "time", ascending: true)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: "Medium")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        var error: NSError? = nil
        if !_fetchedResultsController!.performFetch(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            println("Unresolved error \(error), \(error?.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
}
