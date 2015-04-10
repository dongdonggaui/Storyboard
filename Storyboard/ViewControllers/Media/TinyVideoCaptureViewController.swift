//
//  TinyVideoCaptureViewController.swift
//  Storyboard
//
//  Created by huangluyang on 15/4/10.
//  Copyright (c) 2015年 HLY. All rights reserved.
//

import UIKit

class TinyVideoCaptureViewController: UIViewController {
    
    var previewView: OpenGLPixelBufferView?
    var progressBar: TQTwoSideProgressBar?
    var inferiorContainerView: UIView?
    var captureButton: UIButton?
    var didSetupConstraints = false
    let captureButtonWidth = 150
    
    var timer: NSTimer?
    var timeCounter: NSTimeInterval = 0
    let totalTime: NSTimeInterval = 7
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func updateViewConstraints() {
        
        if !didSetupConstraints {
            previewView!.autoPinEdgeToSuperviewMargin(.Top)
            previewView!.autoPinEdgeToSuperviewMargin(.Left)
            previewView!.autoPinEdgeToSuperviewMargin(.Right)
            previewView!.autoMatchDimension(.Height, toDimension: .Width, ofView: previewView!, withMultiplier: 0.75)
            
            inferiorContainerView!.autoPinEdgeToSuperviewEdge(.Left)
            inferiorContainerView!.autoPinEdgeToSuperviewEdge(.Right)
            inferiorContainerView!.autoPinEdgeToSuperviewEdge(.Bottom)
            inferiorContainerView!.autoPinEdge(.Top, toEdge: .Bottom, ofView: previewView!)
            
            progressBar!.autoPinEdgeToSuperviewEdge(.Left)
            progressBar!.autoPinEdgeToSuperviewEdge(.Right)
            progressBar!.autoPinEdge(.Top, toEdge: .Top, ofView: inferiorContainerView!)
            progressBar!.autoSetDimension(.Height, toSize: 5)
            
            captureButton!.autoSetDimensionsToSize(CGSize(width: captureButtonWidth, height: captureButtonWidth))
            captureButton!.autoCenterInSuperview()
        }
        
        super.updateViewConstraints()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - private
    func setupUI() {
        previewView = OpenGLPixelBufferView(forAutoLayout: ())
        previewView!.backgroundColor = UIColor(white: 0, alpha: 0.9)
        self.view.addSubview(previewView!)
        
        var containerView = UIView.newAutoLayoutView()
        containerView.backgroundColor = UIColor.blackColor()
        self.view.addSubview(containerView)
        inferiorContainerView = containerView
        
        var button = UIButton.buttonWithType(.Custom) as UIButton
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.clipsToBounds = true
        button.layer.cornerRadius = CGFloat(captureButtonWidth) * 0.5
        containerView.addSubview(button)
        captureButton = button
        
        var progressBar = TQTwoSideProgressBar(frame: CGRectZero)
        progressBar.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(progressBar)
        self.progressBar = progressBar
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
