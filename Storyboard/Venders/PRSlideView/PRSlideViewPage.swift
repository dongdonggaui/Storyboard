//
//  PRSlideViewPage.swift
//  PRSlideViewDemo
//
//  Created by Elethom Hunter on 24/01/2015.
//  Copyright (c) 2015 Project Rhinestone. All rights reserved.
//

import UIKit

@objc public class PRSlideViewPage: UIControl {
    public var pageIndex: Int?
    public var pageIdentifier: String
    
    required public init(frame: CGRect, identifier: String) {
        self.pageIdentifier = identifier
        super.init(frame: frame)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com