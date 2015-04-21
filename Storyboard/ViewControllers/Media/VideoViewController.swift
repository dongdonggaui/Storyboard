//
//  VideoViewController.swift
//  Storyboard
//
//  Created by huangluyang on 15/4/8.
//  Copyright (c) 2015年 HLY. All rights reserved.
//

import UIKit
import AVFoundation.AVPlayer
import AVFoundation.AVPlayerItem
import AVFoundation.AVPlayerLayer

class VideoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var playerItems: [AVPlayerItem] = [AVPlayerItem]()
    var players: [AVPlayer] = [AVPlayer]()
    var playerLayers: [AVPlayerLayer] = [AVPlayerLayer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupPlayerItems()
        setupPlayers()
        setupPlayerLayers()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addPlaybackObserver()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        for player in players {
            player.play()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        removePlaybackOberser()
        
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - private
    func setupPlayerItems() {
        var url1 = NSBundle.mainBundle().URLForResource("10411608041575417ed67610", withExtension: "mp4")
        let playerItem1 = AVPlayerItem(URL: url1)
        playerItems.append(playerItem1)
        
        var url2 = NSBundle.mainBundle().URLForResource("10465908041575417ed94771", withExtension: "mp4")
        let playerItem2 = AVPlayerItem(URL: url2)
        playerItems.append(playerItem2)
    }
    
    func setupPlayers() {
        for playerItem in playerItems {
            let player: AVPlayer = AVPlayer.playerWithPlayerItem(playerItem) as! AVPlayer
            player.volume = 0
            players.append(player as AVPlayer)
        }
    }
    
    func setupPlayerLayers() {
        for player in players {
            let playerLayer = AVPlayerLayer(player: player)
            playerLayers.append(playerLayer)
        }
    }
    
    func setupUI() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 295
    }
    
    func addPlaybackObserver() {
        for playerItem in playerItems {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "playbackFinished:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
        }
    }
    
    func removePlaybackOberser() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func playbackFinished(notification: NSNotification) {
        let item = notification.object as! AVPlayerItem
        item.seekToTime(kCMTimeZero)
        var index: Int = 0
        for var i = 0; i < playerItems.count; i++ {
            let playerItem = playerItems[i]
            if playerItem == item {
                index = i
                break
            }
        }
        let player = players[index]
        player.play()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - actions
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        self.performSegueWithIdentifier("<#segue#>", sender: nil)
        let player = players[indexPath.row]
        player.play()
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        var image: UIImage? = nil
        if indexPath.row == 1 {
            image = UIImage(named: "10465908041575417ed94771.jpg")
        } else {
            image = UIImage(named: "10411608041575417ed67610.jpg")
        }
        
        let horizMargin: CGFloat = 10
        
        var imageCover: UIImageView? = cell.contentView.viewWithTag(101) as? UIImageView
        if imageCover == nil {
            imageCover = UIImageView()
            imageCover!.tag = 101
            imageCover!.image = image!
            imageCover!.clipsToBounds = true
            imageCover!.sizeToFit()
            cell.contentView.addSubview(imageCover!)
            imageCover!.setTranslatesAutoresizingMaskIntoConstraints(false)
            imageCover!.autoMatchDimension(ALDimension.Width, toDimension: ALDimension.Width, ofView: cell.contentView, withOffset: -2*horizMargin)
            imageCover!.autoMatchDimension(ALDimension.Height, toDimension: ALDimension.Width, ofView: imageCover!, withMultiplier: 0.75)
//            imageCover!.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5))
            imageCover!.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 10)
            imageCover!.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: horizMargin)
            imageCover!.autoPinEdgeToSuperviewEdge(ALEdge.Bottom, withInset: 10, relation: NSLayoutRelation.GreaterThanOrEqual)
            imageCover!.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: horizMargin)
        }
        
        let playerLayer = playerLayers[indexPath.row] as AVPlayerLayer
        var hasPlayerLayer = false
        for layer in cell.contentView.layer.sublayers {
            if layer as! CALayer == playerLayer {
                hasPlayerLayer = true
                break
            }
        }
        if !hasPlayerLayer {
            cell.contentView.layer.addSublayer(playerLayer)
        }
        let width = CGRectGetWidth(tableView.frame) - 2 * horizMargin
        let height = width * 3.0 / 4
        playerLayer.frame = CGRect(x: horizMargin, y: 10, width: width, height: height)
    }

}
