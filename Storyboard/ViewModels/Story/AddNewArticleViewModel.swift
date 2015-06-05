//
//  AddNewArticleViewModel.swift
//  Storyboard
//
//  Created by huangluyang on 15/6/5.
//  Copyright (c) 2015年 HLY. All rights reserved.
//

import UIKit

class AddNewArticleViewModel: RVMViewModel {
    
    lazy var title: String = ""
    lazy var time: NSDate = NSDate()
    lazy var content: String = ""
    
    var inserting = false
    var canSubmit = false
    
    init(model: Medium) {
        _model = model
        super.init()
        self.model.type = NSNumber(integer: 0)
        RACObserve(self, "title").subscribeNext { (text) -> Void in
            var flag = (text as! NSString).length > 0
            self.canSubmit = flag
        }
        RAC(self.model, "title").assignSignal(RACObserve(self, "title"))
        RAC(self.model, "time").assignSignal(RACObserve(self, "time"))
        RAC(self.model, "content").assignSignal(RACObserve(self, "content"))
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
    
    // MARK: - Getters
    private var _model: Medium
    var model: Medium {
        return _model
    }
}
