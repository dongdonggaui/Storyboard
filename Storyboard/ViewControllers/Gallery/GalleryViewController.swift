//
//  GalleryViewController.swift
//  Storyboard
//
//  Created by huangluyang on 15/3/31.
//  Copyright (c) 2015年 HLY. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController, TQTransitionProtocol, PRSlideViewDataSource {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var slideView: PRSlideView!
    var image: UIImage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageView.image = self.image
        self.slideView.dataSource = self
        self.slideView.registerClass(<#pageClass: PRSlideViewPage.Type#>, identifier: <#String#>)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - transition
    func viewForTransition() -> UIView {
        return self.imageView
    }
    
    // MARK: - slide view data source
    func numberOfPagesInSlideView(slideView: PRSlideView) -> Int {
        return 3
    }
    
    func slideView(slideView: PRSlideView, pageAtIndex index: Int) -> PRSlideViewPage {
        <#code#>
    }
}
