//
//  AddNewAlbumViewModel.swift
//  Storyboard
//
//  Created by huangluyang on 15/6/1.
//  Copyright (c) 2015年 HLY. All rights reserved.
//

import UIKit
import CoreData

class AddNewAlbumViewModel: RVMViewModel, NSFetchedResultsControllerDelegate {
    
    lazy var title: String = ""
    lazy var date: NSDate = NSDate()
    var image: UIImage?
    private var _model: Album
    var model: Album {
        return _model
    }
    var inserting = false
    
    var canSubmit = false
    
    init(model: Album) {
        _model = model
        super.init()
        RACObserve(self, "title").subscribeNext { (text) -> Void in
            var flag = (text as! NSString).length > 0
            self.canSubmit = flag
        }
        RAC(self.model, "name").assignSignal(RACObserve(self, "title"))
        RAC(self.model, "date").assignSignal(RACObserve(self, "date"))
        RACObserve(self, "image").subscribeNext { (theImage) -> Void in
            if theImage != nil {
                self.model.image = UIImageJPEGRepresentation((theImage as! UIImage), 1)
            }
        }
    }
    
    // MARK: - Public
    func cancel() {
        if self.inserting {
            self.model.managedObjectContext!.deleteObject(self.model)
        }
    }
    
    func willDismiss() {
        self.model.managedObjectContext!.save(nil)
    }
}
