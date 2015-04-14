//
//  SmallVideoCaptureViewController.swift
//  Storyboard
//
//  Created by huangluyang on 15/4/9.
//  Copyright (c) 2015年 HLY. All rights reserved.
//

import UIKit
import AVFoundation.AVCaptureDevice
import AVFoundation.AVCaptureInput
import AVFoundation.AVCaptureOutput
import AVFoundation.AVCaptureSession
import AVFoundation.AVCaptureVideoPreviewLayer
import AssetsLibrary

typealias PropertyChangeBlock = (AVCaptureDevice) -> ()

class SmallVideoCaptureViewController: UIViewController, RosyWriterCapturePipelineDelegate {

    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var previewViewContainer: UIView!
    @IBOutlet weak var progressBar: TQTwoSideProgressBar!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var focusCusor: UIImageView!
    
    var previewView: OpenGLPixelBufferView?
    var capturePipeline: RosyWriterCapturePipeline?
    var allowedToUseGPU = false
    var didSetupConstraints = false
    var addedObservers = false
    var recording = false
    var backgroundRecordingID: UIBackgroundTaskIdentifier?
    var didSetupTransform = false
    
    var saveToDisk: Bool = false
    var recordCompleted: Bool = false
    
    var timer: NSTimer?
    var timeCounter: NSTimeInterval = 0
    let totalTime: NSTimeInterval = 7
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        UIDevice.currentDevice().endGeneratingDeviceOrientationNotifications()
    }
    
    override func viewDidLoad() {
        capturePipeline = RosyWriterCapturePipeline()
        capturePipeline!.setDelegate(self, callbackQueue: dispatch_get_main_queue())
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: UIApplication.sharedApplication())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground", name: UIApplicationWillEnterForegroundNotification, object: UIApplication.sharedApplication())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationDidChange", name: UIDeviceOrientationDidChangeNotification, object: UIDevice.currentDevice())
        
        // Keep track of changes to the device orientation so we can update the capture pipeline
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        
        addedObservers = true
        
        // the willEnterForeground and didEnterBackground notifications are subsequently used to update _allowedToUseGPU
        allowedToUseGPU = (UIApplication.sharedApplication().applicationState != .Background)
        capturePipeline!.renderingEnabled = allowedToUseGPU
        
        super.viewDidLoad()

        setupUI()
    }
    
    override func updateViewConstraints() {
        
        super.updateViewConstraints()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        capturePipeline!.startRunning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        capturePipeline!.stopRunning()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientationMask.Portrait.rawValue.hashValue
    }
    
    // MARK: - notification
    func applicationDidEnterBackground() {
        // Avoid using the GPU in the background
        allowedToUseGPU = false
        capturePipeline!.renderingEnabled = false
        
        capturePipeline!.stopRecording()
        
        // We reset the OpenGLPixelBufferView to ensure all resources have been clear when going to the background.
        previewView!.reset()
    }
    
    func applicationWillEnterForeground() {
        allowedToUseGPU = true
        capturePipeline!.renderingEnabled = true
    }
    
    func deviceOrientationDidChange() {
        let deviceOrientation = UIDevice.currentDevice().orientation
        if UIDeviceOrientationIsPortrait(deviceOrientation) || UIDeviceOrientationIsLandscape(deviceOrientation) {
            capturePipeline!.recordingOrientation = AVCaptureVideoOrientation(rawValue: deviceOrientation.rawValue)!
        }
    }
    
    // MARK: - private
    func setupUI() {
        let cancelItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelButtonDidTapped")
        navigationItem.leftBarButtonItem = cancelItem
        
        captureButton.addTarget(self, action: "captureButtonDidTouchDown:", forControlEvents: UIControlEvents.TouchDown)
        captureButton.addTarget(self, action: "captureButtonDidTouchUpInside:", forControlEvents: UIControlEvents.TouchUpInside)
        captureButton.addTarget(self, action: "captureButtonDidTouchCancelled:", forControlEvents: UIControlEvents.TouchCancel)
        captureButton.addTarget(self, action: "captureButtonDidTouchDragExit:", forControlEvents: UIControlEvents.TouchDragExit)
        captureButton.addTarget(self, action: "captureButtonDidTouchDragEnter:", forControlEvents: UIControlEvents.TouchDragEnter)
        captureButton.addTarget(self, action: "captureButtonDidTouchCancelled:", forControlEvents: UIControlEvents.TouchUpOutside)
        promptLabel.alpha = 0
        promptLabel.font = UIFont.systemFontOfSize(14)
        resetProgressBar()
    }
    
    func setupPreviewView() {
        previewView = OpenGLPixelBufferView(forAutoLayout: ())
        previewView!.backgroundColor = UIColor(white: 0, alpha: 0.9)
        var currentInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        previewView!.transform = capturePipeline!.transformFromVideoBufferOrientationToOrientation(AVCaptureVideoOrientation(rawValue: currentInterfaceOrientation.rawValue)!, withAutoMirroring: true)
        previewViewContainer.insertSubview(previewView!, belowSubview: promptLabel)
        
        var bounds = CGRectZero
        bounds.size = previewViewContainer!.convertRect(previewViewContainer!.bounds, toView: previewView!).size
        previewView!.bounds = bounds
        previewView!.center = CGPointMake(previewViewContainer!.bounds.size.width/2.0, previewViewContainer!.bounds.size.height/2.0)
    }
    
    func showCancelPrompt() {
        promptLabel.text = "上移取消"
        promptLabel.alpha = 0
        promptLabel.backgroundColor = UIColor.clearColor()
        promptLabel.textColor = UIColor.greenColor()
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.promptLabel.alpha = 1
        })
    }
    
    func showConfirmPrompt() {
        promptLabel.text = "放开取消"
        promptLabel.alpha = 0
        promptLabel.backgroundColor = UIColor.redColor()
        promptLabel.textColor = UIColor.whiteColor()
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.promptLabel.alpha = 1
        })
    }
    
    func dismissPrompt() {
        promptLabel.alpha = 0
    }
    
    func resetProgressBar() {
        timeCounter = 0
        progressBar.progress = 0
        progressBar.hidden = true
    }
    
    func updateProgressBar(progress: CGFloat) {
        progressBar.hidden = false
        progressBar.progress = progress
    }
    
    func startRecord() {
    }
    
    func recordingStopped() {
        recording = false
        
        UIApplication.sharedApplication().idleTimerDisabled = false
        UIApplication.sharedApplication().endBackgroundTask(backgroundRecordingID!)
        
        backgroundRecordingID = UIBackgroundTaskInvalid;
    }
    
    func stopRecordAndSave(saveOrNot: Bool) {

        saveToDisk = saveOrNot
    }
    
    // MARK: - actions
    func cancelButtonDidTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func captureButtonDidTouchDown(sender: UIButton) {
        if recordCompleted {
            return
        }
        
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerTikTok", userInfo: nil, repeats: true)
        showCancelPrompt()
        startRecord()
    }
    
    func captureButtonDidTouchUpInside(sender: UIButton) {
        if recordCompleted {
            return
        }
        
        timer?.invalidate()
        dismissPrompt()
        resetProgressBar()
        stopRecordAndSave(true)
    }
    
    func captureButtonDidTouchDragExit(sender: UIButton) {
        println("outside")
        showConfirmPrompt()
    }
    
    func captureButtonDidTouchDragEnter(sender: UIButton) {
        println("inside")
        showCancelPrompt()
    }
    
    func captureButtonDidTouchCancelled(sender: UIButton) {
        timer?.invalidate()
        dismissPrompt()
        resetProgressBar()
    }
    
    func timerTikTok() {
        if timeCounter < totalTime {
            timeCounter++
        } else {
            dismissPrompt()
            recordCompleted = true
            stopRecordAndSave(true)
        }
        updateProgressBar(CGFloat(timeCounter / totalTime))
    }
    
    // MARK: - gestures
    func addGenstureRecognizer() {
        var tap = UITapGestureRecognizer(target: self, action: "tapScreen:")
        previewView!.addGestureRecognizer(tap)
    }
    
    func tapScreen(tap: UITapGestureRecognizer) {
        
    }
    
    // MARK: - RosyWriterCapturePipelineDelegate
    func capturePipeline(capturePipeline: RosyWriterCapturePipeline!, didStopRunningWithError error: NSError!) {
        
    }
    
    // Preview
    func capturePipeline(capturePipeline: RosyWriterCapturePipeline!, previewPixelBufferReadyForDisplay previewPixelBuffer: CVPixelBuffer!) {
        if !allowedToUseGPU {
            return
        }
        
        // must set transform at here or the rotation will wrong
        if previewView == nil {
            setupPreviewView()
        }
        
        previewView!.displayPixelBuffer(previewPixelBuffer)
    }
    
    func capturePipelineDidRunOutOfPreviewBuffers(capturePipeline: RosyWriterCapturePipeline!) {
        if allowedToUseGPU {
            previewView!.flushPixelBufferCache()
        }
    }
    
    // Recording
    func capturePipelineRecordingDidStart(capturePipeline: RosyWriterCapturePipeline!) {
        
    }
    
    func capturePipelineRecordingWillStop(capturePipeline: RosyWriterCapturePipeline!) {
        
    }
    
    func capturePipelineRecordingDidStop(capturePipeline: RosyWriterCapturePipeline!) {
        recordingStopped()
    }
    
    func capturePipeline(capturePipeline: RosyWriterCapturePipeline!, recordingDidFailWithError error: NSError!) {
        recordingStopped()
    }
}
