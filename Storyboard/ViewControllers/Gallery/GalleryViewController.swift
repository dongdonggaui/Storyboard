//
//  GalleryViewController.swift
//  Storyboard
//
//  Created by huangluyang on 15/3/31.
//  Copyright (c) 2015年 HLY. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController, TQTransitionDelegate, PRSlideViewDataSource, PRSlideViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var slideView: PRSlideView!
    
    var image: UIImage?
    var totalImageCount: Int
    var currentImageIndex: Int
    var topTitleLabel: UILabel?
    var statusBarHidden: Bool = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        totalImageCount = 0
        currentImageIndex = 0
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.automaticallyAdjustsScrollViewInsets = false
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageView.image = self.image
        self.slideView.dataSource = self
        self.slideView.delegate = self
        self.slideView.registerClass(GalleryPage.self, identifier: GalleryPage.description())
        self.slideView.hidden = true
        
        if topTitleLabel == nil {
            topTitleLabel = UILabel()
            topTitleLabel!.font = UIFont.boldSystemFontOfSize(20)
            topTitleLabel!.text = String(format: "\(currentImageIndex+1)/\(totalImageCount)")
            topTitleLabel!.sizeToFit()
            self.navigationItem.titleView = topTitleLabel
        }
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: Selector("handlePinchGesture:"))
        pinchGesture.delegate = self
        self.view.addGestureRecognizer(pinchGesture)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let index = currentImageIndex
        slideView.reloadData()
        let width: CGFloat = CGRectGetWidth(self.view.frame)
        slideView.setContentOffset(CGPointMake(width * CGFloat(index), 0), animated: false)
        currentImageIndex = index
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        slideView.hidden = false
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        println("update contraints --> \(self.slideView.frame)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        println("slide view frame --> \(self.slideView.frame)")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        setStatusBarAndNavigationBarHidden(false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Slide
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return statusBarHidden
    }
    
    // MARK: - private
    func setStatusBarAndNavigationBarHidden(flag: Bool) {
        statusBarHidden = flag
        if let nav = self.navigationController {
            nav.setNavigationBarHidden(flag, animated: true)
        }
        self.setNeedsStatusBarAppearanceUpdate()
    }

    // MARK: - gesture handler
    func handlePinchGesture(pinch: UIPinchGestureRecognizer) {
        if pinch.state == .Began {
            slideView.hidden = true
        } else if pinch.state == .Ended || pinch.state == .Cancelled {
            slideView.hidden = false
        }
    }

    // MARK: - transition
    func viewForTransition() -> UIView {
        return self.imageView
    }
    
    func pinchCancelled() {
        println("cancelled")
        setStatusBarAndNavigationBarHidden(statusBarHidden)
    }
    
    // MARK: - slide view data source
    func numberOfPagesInSlideView(slideView: PRSlideView) -> Int {
        return totalImageCount
    }
    
    func slideView(slideView: PRSlideView, pageAtIndex index: Int) -> PRSlideViewPage {
        let page: GalleryPage = slideView.dequeueReusablePageWithIdentifier(GalleryPage.description(), index: index) as GalleryPage
        
//        let imageName: String = self.albumData[index].stringByAppendingPathExtension("jpg")!
        page.coverImageView.image = image
        
        return page
    }
    
    // MARK: - slide view delegate
    func slideView(slideView: PRSlideView, didClickPageAtIndex index: Int) {
        println("tapped at index --> \(index)")
        setStatusBarAndNavigationBarHidden(!statusBarHidden)
    }
    
    func slideView(slideView: PRSlideView, didScrollToPageAtIndex index: Int) {
        currentImageIndex = index
        topTitleLabel!.text = String(format: "\(currentImageIndex+1)/\(totalImageCount)")
        var page: GalleryPage? = slideView.pageAtIndex(index) as? GalleryPage
        if page != nil {
            self.imageView.image = page!.coverImageView.image
        }
    }
    
    // MARK: - gesture delegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
