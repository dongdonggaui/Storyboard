//
//  StoryMediumCell.swift
//  Storyboard
//
//  Created by huangluyang on 15/6/4.
//  Copyright (c) 2015年 HLY. All rights reserved.
//

import UIKit

class StoryMediumCell: UITableViewCell {
    var viewModel: MediumViewModel? = nil {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
