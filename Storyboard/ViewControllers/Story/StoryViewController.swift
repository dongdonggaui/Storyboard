//
//  StoryViewController.swift
//  Storyboard
//
//  Created by huangluyang on 15/3/30.
//  Copyright (c) 2015年 HLY. All rights reserved.
//

import UIKit

class StoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath) as UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        self.performSegueWithIdentifier("<#segue#>", sender: nil)
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
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
    }

}
