//
//  HomeViewModel.swift
//  Storyboard
//
//  Created by huangluyang on 15/6/3.
//  Copyright (c) 2015年 HLY. All rights reserved.
//

import UIKit
import CoreData

class HomeViewModel: RVMViewModel, NSFetchedResultsControllerDelegate {
    lazy private var _updatedContentSignal: RACSignal = RACSubject()
    var updatedContentSignal: RACSignal {
        return _updatedContentSignal
    }
    var albums: [StoryViewModel] = [StoryViewModel]()
    
    var managedObjectContext: NSManagedObjectContext {
        return ASHCoreDataStack.defaultStack().managedObjectContext
    }
    
    override init() {
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
    
    func titleAtIndexPath(indexPath: NSIndexPath) -> String {
        var album = self.albumAtIndexPath(indexPath)
        return album.name
    }
    
    func imageAtIndexPath(indexPath: NSIndexPath) -> UIImage? {
        var album = self.albumAtIndexPath(indexPath)
        return UIImage(data: album.image)
    }
    
    func dateAtIndexPath(indexPath: NSIndexPath) -> NSDate {
        var album = self.albumAtIndexPath(indexPath)
        return album.date
    }
    
    func storyViewModelForIndexPath(indexPath: NSIndexPath) -> StoryViewModel {
        let album = self.albumAtIndexPath(indexPath)
        let storyViewModel = StoryViewModel(model: album)
        return storyViewModel
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
    func albumAtIndexPath(indexPath: NSIndexPath) -> Album {
        return self.fetchedResultsController.objectAtIndexPath(indexPath) as! Album
    }
    
    func insertNewObject() {
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) as! NSManagedObject
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
//        newManagedObject.setValue(date, forKey: "date")
//        newManagedObject.setValue(title, forKey: "name")
//        if image != nil {
//            newManagedObject.setValue(UIImageJPEGRepresentation(image!, 1), forKey: "image")
//        }
        
        // Save the context.
        var error: NSError? = nil
        if !context.save(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            println("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
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
        let entity = NSEntityDescription.entityForName("Album", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: "Album")
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
