//
//  TQTwoSideProgressBar.swift
//  Storyboard
//
//  Created by huangluyang on 15/4/9.
//  Copyright (c) 2015年 HLY. All rights reserved.
//

import UIKit

class TQTwoSideProgressBar: UIControl {

    var progress: CGFloat = 0.0 {
        didSet {
            didProgressChanged = true
            setNeedsUpdateConstraints()
            setNeedsLayout()
        }
    }
    var foregroundView: UIView!
    var backgroundView: UIView!
    var didSetupConstraints = false
    var didProgressChanged = false
    var foregroundViewWidthConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        foregroundView = UIView.newAutoLayoutView()
        backgroundView = UIView.newAutoLayoutView()
        
        addSubview(backgroundView)
        addSubview(foregroundView)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        foregroundView = UIView.newAutoLayoutView()
        foregroundView.backgroundColor = UIColor.orangeColor()
        backgroundView = UIView.newAutoLayoutView()
        backgroundView.backgroundColor = UIColor.lightGrayColor()
        
        addSubview(backgroundView)
        addSubview(foregroundView)
    }

    required init(coder aDecoder: NSCoder) {
        foregroundView = UIView.newAutoLayoutView()
        foregroundView.backgroundColor = UIColor.orangeColor()
        backgroundView = UIView.newAutoLayoutView()
        backgroundView.backgroundColor = UIColor.lightGrayColor()
        
        super.init(coder: aDecoder)
        
        addSubview(backgroundView)
        addSubview(foregroundView)
    }

    override func updateConstraints() {
        if !didSetupConstraints {
            backgroundView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
            foregroundView.autoMatchDimension(.Height, toDimension: .Height, ofView: backgroundView)
            foregroundView.autoCenterInSuperview()
            
            didSetupConstraints = true
        }
        
        if didProgressChanged {
            foregroundViewWidthConstraint?.autoRemove()
            foregroundViewWidthConstraint = foregroundView.autoMatchDimension(.Width, toDimension: .Width, ofView: backgroundView, withMultiplier: 1-progress)
        }
        
        super.updateConstraints()
    }
}
