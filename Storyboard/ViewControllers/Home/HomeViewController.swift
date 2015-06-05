//
//  HomeViewController.swift
//  Storyboard
//
//  Created by huangluyang on 15/3/30.
//  Copyright (c) 2015年 HLY. All rights reserved.
//

import UIKit
import CoreData

class HomeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var homeImageView: UIImageView!
    @IBOutlet weak var homeTitleLabel: UILabel!
}

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var viewModel: HomeViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var backItem = UIBarButtonItem()
        backItem.title = "返回"
        self.navigationItem.backBarButtonItem = backItem
        self.navigationController?.view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.title = "Storyboard"
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        self.tableView.separatorStyle = .None
        
        if let vm = self.viewModel {
            vm.updatedContentSignal.subscribeNext({ (any) -> Void in
                if let signal: String = (any as? String) {
                    if signal == "will" {
                        self.tableView.beginUpdates()
                    } else if signal == "did" {
                        self.tableView.endUpdates()
                    }
                } else if let dic: Dictionary<String, AnyObject> = (any as? Dictionary<String, AnyObject>) {
                    let type = dic["type"] as! String
                    let changeType = dic["changeType"] as! String
                    if type == "section" {
                        var sectionIndex = (dic["section"] as! NSNumber).integerValue
                        switch changeType {
                        case "insert":
                            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                        case "delete":
                            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                        default:
                            return
                        }
                    } else if type == "indexPath" {
                        var newIndexPath: NSIndexPath? = dic["newIndexPath"] as? NSIndexPath
                        var indexPath: NSIndexPath? = dic["indexPath"] as? NSIndexPath
                        switch changeType {
                        case "insert":
                            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                        case "delete":
                            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                        case "update":
                            self.self.configureCell(self.tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
                        case "move":
                            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                        default:
                            return
                        }
                    }
                }
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel?.active = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.viewModel?.active = false
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            var indexPath = sender as! NSIndexPath
            let storyViewModel = self.viewModel!.storyViewModelForIndexPath(indexPath)
            let vc = segue.destinationViewController as! StoryViewController
            vc.viewModel = storyViewModel
        } else if segue.identifier == "showAdd" {
            let album = NSEntityDescription.insertNewObjectForEntityForName("Album", inManagedObjectContext: ASHCoreDataStack.defaultStack().managedObjectContext) as! Album
            
            let nc = segue.destinationViewController as? UINavigationController
            if let vc = nc?.topViewController as? AddNewAlbumViewController {
                var vm = AddNewAlbumViewModel(model: album)
                vm.inserting = true
                vc.viewModel = vm
            }
        }
    }
    
    // MARK: - private
    
    func insertNewObject(sender: AnyObject) {
        performSegueWithIdentifier("showAdd", sender: nil)
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
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        self.configureCell(cell, atIndexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            self.viewModel?.deleteObjectAtIndexPath(indexPath)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showDetail", sender: indexPath)
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let homeCell = cell as! HomeTableViewCell
        var time = self.viewModel?.dateAtIndexPath(indexPath).description ?? "2015-11-08"
        var name = self.viewModel?.titleAtIndexPath(indexPath) ?? "马尔代夫"
        homeCell.homeTitleLabel!.text = String(format: "\(name) \(time)")
        homeCell.homeImageView!.image = self.viewModel?.imageAtIndexPath(indexPath)
    }
    
    // MARK: - scroll view delegate
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset = scrollView.contentOffset.y
        if offset <= -200 {
            let vc: SmallVideoCaptureViewController = SmallVideoCaptureViewController(nibName: "SmallVideoCaptureViewController", bundle: nil)
            let nc: UINavigationController = UINavigationController(rootViewController: vc)
            self.presentViewController(nc, animated: true, completion: nil)
        }
    }
}
