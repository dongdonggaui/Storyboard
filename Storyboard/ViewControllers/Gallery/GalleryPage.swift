//
//  GalleryPage.swift
//  Storyboard
//
//  Created by huangluyang on 15/4/1.
//  Copyright (c) 2015年 HLY. All rights reserved.
//

import UIKit

public class GalleryPage: PRSlideViewPage {

    public private(set) var coverImageView: UIImageView
    private var galleryContext = 0
    
    required public init(frame: CGRect, identifier: String) {
        self.coverImageView = UIImageView()
        
        super.init(frame: frame, identifier: identifier)
        
        let coverImageView = self.coverImageView
//        coverImageView.frame = self.bounds
        coverImageView.clipsToBounds = true
//        coverImageView.autoresizingMask = (.FlexibleWidth | .FlexibleHeight)
        coverImageView.contentMode = .ScaleAspectFill
        self.addSubview(coverImageView)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        
        var image: UIImage? = self.coverImageView.image
        if image != nil {
            let size = self.frame.size
            let imageSize = image!.size
            let scale = imageSize.height / imageSize.width
            let width = size.width
            let height = ceil(width * scale)
            let point = CGPoint(x: ceil(width * 0.5), y: ceil(size.height * 0.5))
            self.coverImageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            self.coverImageView.center = point
            
            println("image height = \(height), center = \(point)")
        }
    }
}
