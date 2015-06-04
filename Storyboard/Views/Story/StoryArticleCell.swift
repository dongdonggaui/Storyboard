//
//  StoryArticleCell.swift
//  Storyboard
//
//  Created by huangluyang on 15/6/4.
//  Copyright (c) 2015年 HLY. All rights reserved.
//

import UIKit

class StoryArticleCell: UITableViewCell {
    var hasSetupConstraints = false
    var viewModel: Medium?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func updateConstraints() {
        if !self.hasSetupConstraints {
            self.articleTitleLabel.autoPinEdgeToSuperviewEdge(.Left withInset: 10)
            self.articleTitleLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 10)
            self.articleTitleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 5)
            self.articleTimeLabel.autoPinEdge(.Left, toEdge: .Left, ofView: self.articleTitleLabel)
            self.articleTimeLabel.autoPinEdge(.Right, toEdge: .Right, ofView: self.articleTitleLabel)
            self.articleTimeLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.articleTitleLabel, withOffset: 8)
            self.articleContentLabel.autoPinEdge(.Left, toEdge: .Left, ofView: self.articleTitleLabel)
            self.articleContentLabel.autoPinEdge(.Right, toEdge: .Right, ofView: self.articleTitleLabel)
            self.articleContentLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.articleTimeLabel, withOffset: 8)
            self.articleContentLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 5)
            self.hasSetupConstraints = true
        }
        super.updateConstraints()
    }
    // MARK: - Private
    func setupUI() {
        self.contentView.addSubview(self.articleTitleLabel)
        self.contentView.addSubview(self.articleTimeLabel)
        self.contentView.addSubview(self.articleContentLabel)
    }
    
    // MARK: - Getters
    private var _articleTitleLabel: UILabel?
    private var _articleTimeLabel: UILabel?
    private var _articleContentLabel: UILabel?
    var articleTitleLabel: UILabel {
        if _articleTitleLabel == nil {
            _articleTitleLabel = UILabel()
            _articleTitleLabel!.font = UIFont.boldSystemFontOfSize(16)
        }
        return _articleTitleLabel
    }
    
    var articleTimeLabel: UILabel {
        if _articleTimeLabel == nil {
            _articleTimeLabel = UILabel()
            _articleTimeLabel!.font = UIFont.systemFontOfSize(12)
        }
        return _articleTimeLabel
    }
    
    var articleContentLabel: UILabel {
        if _articleContentLabel == nil {
            _articleContentLabel = UILabel()
            _articleContentLabel!.font = UIFont.systemFontOfSize(14)
        }
        return _articleContentLabel
    }
}
