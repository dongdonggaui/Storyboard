//
//  StoryViewController.swift
//  Storyboard
//
//  Created by huangluyang on 15/3/30.
//  Copyright (c) 2015年 HLY. All rights reserved.
//

import UIKit

class TimeLineCell: UITableViewCell {
    
    @IBOutlet weak var timeLineImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var tapAction: (() -> Void)?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.tapAction = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.timeLineImageView.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "imageViewTapped:")
        self.timeLineImageView.addGestureRecognizer(tap)
    }
    
    // MARK: - actions
    func imageViewTapped(sender: UITapGestureRecognizer) {
        if self.tapAction != nil {
            self.tapAction!()
        }
    }
}

class StoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.segmentedControl.addTarget(self, action: "segmentedControlValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 150.0
        self.tableView.registerClass(NSClassFromString("UITableViewHeaderFooterView"), forHeaderFooterViewReuseIdentifier: "header")
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
//        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    func segmentedControlValueChanged(sender: UISegmentedControl) {
        self.tableView.reloadData()
        self.tableView.separatorStyle = segmentedControl.selectedSegmentIndex == 0 ? UITableViewCellSeparatorStyle.None : UITableViewCellSeparatorStyle.SingleLine
    }

    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.segmentedControl.selectedSegmentIndex == 0 ? 2 : 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier: NSString = self.segmentedControl.selectedSegmentIndex == 0 ? "TimeLineCell" : "CategoryCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.segmentedControl.selectedSegmentIndex == 1 {
            if indexPath.row == 0 {
                self.performSegueWithIdentifier("showImages", sender: nil)
            } else if indexPath.row == 1 {
                self.performSegueWithIdentifier("showArticles", sender: nil)
            } else if indexPath.row == 2 {
                self.performSegueWithIdentifier("showSmallVideos", sender: nil)
            } else if indexPath.row == 3 {
                self.performSegueWithIdentifier("showVideos", sender: nil)
            } else {
                self.performSegueWithIdentifier("showAudeos", sender: nil)
            }
        }
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        if self.segmentedControl.selectedSegmentIndex == 1 {
            if indexPath.row == 0 {
                cell.textLabel!.text = "照片"
            } else if indexPath.row == 1 {
                cell.textLabel!.text = "文章"
            } else if indexPath.row == 2 {
                cell.textLabel!.text = "小视频"
            } else if indexPath.row == 3 {
                cell.textLabel!.text = "视频"
            } else {
                cell.textLabel!.text = "音频"
            }
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        } else {
            let timeLineCell = cell as TimeLineCell
            let time = NSDate().description
            timeLineCell.timeLabel.text = time;
            timeLineCell.selectionStyle = UITableViewCellSelectionStyle.None
            var location = "武汉"
            var address = "武汉天河国际机场"
            var description = "要出发了，好嗨森"
            if indexPath.row == 0 {
                timeLineCell.timeLineImageView.image = UIImage(named: "pl_wuhan.jpg")
            } else {
                location = "马累"
                address = "Male International Airport"
                description = "顺利到达"
                timeLineCell.timeLineImageView.image = UIImage(named: "pl1.jpg")
            }
            let date = NSString(format: "第\(indexPath.row + 1)天 \(location)")
            timeLineCell.addressLabel.text = address
            timeLineCell.descriptionLabel.text = description
            timeLineCell.tapAction = {
                println("tapped at indexPath \(indexPath)")
            }
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.segmentedControl.selectedSegmentIndex == 0 {
            var view: UITableViewHeaderFooterView? = (tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as UITableViewHeaderFooterView)
            
            let viewWidth = CGRectGetWidth(tableView.frame)
            let viewHeight: CGFloat = 30
            view!.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
            view!.contentView.backgroundColor = UIColor.whiteColor()
            
            var line: UIView? = view!.contentView.viewWithTag(101)
            if line == nil {
                line = UIView()
                line!.tag = 101
                line!.backgroundColor = UIColor.lightGrayColor()
                line!.frame = CGRect(x: 13, y: 0, width: 2, height: 30)
                view!.contentView.addSubview(line!)
            }
            
            var point: UIView? = view!.contentView.viewWithTag(102)
            if point == nil {
                point = UIView()
                point!.tag = 102
                point!.backgroundColor = UIColor.lightGrayColor()
                point!.frame = CGRect(x: 10, y: 13, width: 8, height: 8)
                point!.layer.cornerRadius = 4
                view!.contentView.addSubview(point!)
            }
            
            var label: UILabel? = view!.contentView.viewWithTag(103) as? UILabel
            if label == nil {
                label = UILabel()
                label!.tag = 103
                label!.font = UIFont.systemFontOfSize(15)
                label!.backgroundColor = UIColor.clearColor()
                view!.contentView.addSubview(label!)
            }
            label!.text = "第1天 武汉"
            label!.sizeToFit()
            var frame = label!.frame;
            frame.origin.x = CGRectGetMaxX(point!.frame) + 8;
            frame.origin.y = (viewHeight - frame.size.height) * 0.5
            label!.frame = frame
            
            return view!
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.segmentedControl.selectedSegmentIndex == 0 ? 30 : 0
    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 150.0
//    }
}
