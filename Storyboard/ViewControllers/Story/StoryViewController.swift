//
//  StoryViewController.swift
//  Storyboard
//
//  Created by huangluyang on 15/3/30.
//  Copyright (c) 2015年 HLY. All rights reserved.
//

import UIKit

typealias testBlock = DidSelectedItemBlock

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

class StoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TQTransitionDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var transition: TQTransition?
    var viewModel: StoryViewModel?
    var selectedIndexPath: NSIndexPath?
    
    var hasSetupConstraints = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.orangeColor()
        let transition = TQTransition(navigationController: self.navigationController!)
        self.navigationController!.delegate = transition
        self.transition = transition

        self.segmentedControl.addTarget(self, action: "segmentedControlValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 150.0
        self.tableView.registerClass(NSClassFromString("UITableViewHeaderFooterView"), forHeaderFooterViewReuseIdentifier: "header")
        self.tableView.registerClass(NSClassFromString("StoryMediumCell"), forCellReuseIdentifier: "Cell")
        self.tableView.separatorStyle = .None
//        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        
        self.view.addSubview(self.addSegmentButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func updateViewConstraints() {
        if !self.hasSetupConstraints {
            self.addSegmentButton.autoSetDimensionsToSize(CGSizeMake(60, 60))
            self.addSegmentButton.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 10)
            self.addSegmentButton.autoAlignAxisToSuperviewAxis(.Vertical)
            self.hasSetupConstraints = true
        }
        super.updateViewConstraints()
    }
    
    // MARK: - Actions
    func segmentedControlValueChanged(sender: UISegmentedControl) {
        self.tableView.reloadData()
        self.tableView.separatorStyle = segmentedControl.selectedSegmentIndex == 0 ? UITableViewCellSeparatorStyle.None : UITableViewCellSeparatorStyle.SingleLine
    }

    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.viewModel?.numberOfSections() ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.numberOfItemsInSection(section) ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
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
        var medium = self.viewModel?.mediumAtIndexPath(indexPath)
        if self.viewModel?.displayStyle == .Timeline {
            
        } else if self.viewModel?.displayStyle == .Category {
            
        }
//        if self.segmentedControl.selectedSegmentIndex == 1 {
//            if indexPath.row == 0 {
//                cell.textLabel!.text = "照片"
//            } else if indexPath.row == 1 {
//                cell.textLabel!.text = "文章"
//            } else if indexPath.row == 2 {
//                cell.textLabel!.text = "小视频"
//            } else if indexPath.row == 3 {
//                cell.textLabel!.text = "视频"
//            } else {
//                cell.textLabel!.text = "音频"
//            }
//            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
//        } else {
//            let timeLineCell = cell as! TimeLineCell
//            let time = NSDate().description
//            timeLineCell.timeLabel.text = time;
//            timeLineCell.selectionStyle = UITableViewCellSelectionStyle.None
//            var location = "武汉"
//            var address = "武汉天河国际机场"
//            var description = "要出发了，好嗨森"
//            if indexPath.row == 0 {
//                timeLineCell.timeLineImageView.image = UIImage(named: "pl_wuhan.jpg")
//            } else {
//                location = "马累"
//                address = "Male International Airport"
//                description = "顺利到达"
//                timeLineCell.timeLineImageView.image = UIImage(named: "pl1.jpg")
//            }
//            let date = NSString(format: "第\(indexPath.row + 1)天 \(location)")
//            timeLineCell.addressLabel.text = address
//            timeLineCell.descriptionLabel.text = description
//            timeLineCell.tapAction = {
//                println("tapped at indexPath \(indexPath)")
//                self.selectedIndexPath = indexPath
//                let vc = GalleryViewController(nibName: "GalleryViewController", bundle: nil)
//                vc.image = timeLineCell.timeLineImageView.image
//                vc.currentImageIndex = indexPath.row
//                vc.totalImageCount = 5
//                self.navigationController!.pushViewController(vc, animated: true)
//            }
//        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.segmentedControl.selectedSegmentIndex == 0 {
            var view: UITableViewHeaderFooterView? = (tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! UITableViewHeaderFooterView)
            
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
    
    // MARK: - TQTransitionDelegate
    func viewForTransition() -> UIView {
        let cell = self.tableView.cellForRowAtIndexPath(self.selectedIndexPath!) as! TimeLineCell
        return cell.timeLineImageView
    }
    
    func pinchCancelled() {
        
    }
    
    // MARK: - Event Response
    func addSegment() {
        var items: [MenuItem] = []
        var menuItemPhoto = MenuItem(title: "照片", iconName: "camera_focus_red", glowColor: UIColor.grayColor(), index: 0)
        items.append(menuItemPhoto)
        var menuItemArticle = MenuItem(title: "日记", iconName: "camera_focus_red", glowColor: UIColor.grayColor(), index: 1)
        items.append(menuItemArticle)
        var menuItemTinyVideo = MenuItem(title: "小视频", iconName: "camera_focus_red", glowColor: UIColor.grayColor(), index: 2)
        items.append(menuItemTinyVideo)
        var menuItemVideo = MenuItem(title: "视频", iconName: "camera_focus_red", glowColor: UIColor.grayColor(), index: 3)
        items.append(menuItemVideo)
        var menuItemAudio = MenuItem(title: "声音", iconName: "camera_focus_red", glowColor: UIColor.grayColor(), index: 4)
        items.append(menuItemAudio)
        
        var popMenu = PopMenu(frame: self.view.bounds, items: items)
        var block: testBlock = { (item: MenuItem!) -> Void in
            println("tapped at \(item.index)")
        }
        popMenu.didSelectedItemCompletion = block
        popMenu.showMenuAtView(UIApplication.sharedApplication().keyWindow)
    }
    
    // MARK: - Getters
    private var _addSegmentButton: UIButton?
    var addSegmentButton: UIButton {
        if _addSegmentButton == nil {
            _addSegmentButton = UIButton()
            _addSegmentButton!.setBackgroundImage(UIImage(color: UIColor.orangeColor()), forState: .Normal)
            _addSegmentButton!.layer.cornerRadius = 30
            _addSegmentButton!.clipsToBounds = true
            _addSegmentButton!.addTarget(self, action: "addSegment", forControlEvents: .TouchUpInside)
        }
        return _addSegmentButton!
    }
}
