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

class SmallVideoCaptureViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {

    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var progressBar: TQTwoSideProgressBar!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var focusCusor: UIImageView!
    
    var captureSession: AVCaptureSession?                       //负责输入和输出设置之间的数据传递
    var captureDeviceInput: AVCaptureDeviceInput?               //负责从AVCaptureDevice获得输入数据
    var captureMovieFileOutput: AVCaptureMovieFileOutput?       //视频输出流
    var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer?   //相机拍摄预览图层
    var enableRotation: Bool = false                            //是否允许旋转（注意在视频录制过程中禁止屏幕旋转）
    var lastBounds: CGRect?                                     //旋转的前大小
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?   //后台任务标识
    var saveToDisk: Bool = false
    var recordCompleted: Bool = false
    
    var timer: NSTimer?
    var timeCounter: NSTimeInterval = 0
    let totalTime: NSTimeInterval = 7
    
    deinit {
        removeNotification()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //初始化会话
        captureSession = AVCaptureSession()
        if captureSession!.canSetSessionPreset(AVCaptureSessionPreset640x480) {
            captureSession!.sessionPreset = AVCaptureSessionPreset640x480
        }
        
        //获得输入设备
        var captureDevice: AVCaptureDevice? = self.getCameraDeviceWithPosition(.Back)//取得后置摄像头
        if (captureDevice == nil) {
            println("取得后置摄像头时出现问题.");
            return;
        }
        //添加一个音频输入设备
        var audioCaptureDevice: AVCaptureDevice = AVCaptureDevice.devicesWithMediaType(AVMediaTypeAudio).first as AVCaptureDevice
        
        var error: NSError? = nil
        //根据输入设备初始化设备输入对象，用于获得输入数据
        captureDeviceInput = AVCaptureDeviceInput(device: captureDevice, error: &error)
        if error != nil {
            println("取得设备输入对象时出错，错误原因：\(error!.localizedDescription)");
            return;
        }
        var audioCaptureDeviceInput: AVCaptureDeviceInput = AVCaptureDeviceInput(device: audioCaptureDevice, error: &error)
        if error != nil {
            println("取得设备输入对象时出错，错误原因：\(error!.localizedDescription)");
            return;
        }
        //初始化设备输出对象，用于获得输出数据
        captureMovieFileOutput = AVCaptureMovieFileOutput()
        
        //将设备输入添加到会话中
        if captureSession!.canAddInput(captureDeviceInput) {
            captureSession!.addInput(captureDeviceInput)
            captureSession!.addInput(audioCaptureDeviceInput)
            var captureConnection: AVCaptureConnection? = captureMovieFileOutput!.connectionWithMediaType(AVMediaTypeVideo)
            if (captureConnection != nil && captureConnection!.supportsVideoStabilization) {
                captureConnection!.preferredVideoStabilizationMode = .Auto
            }
        }
        
        //将设备输出添加到会话中
        if captureSession!.canAddOutput(captureMovieFileOutput) {
            captureSession!.addOutput(captureMovieFileOutput)
        }
        
        //创建视频预览层，用于实时展示摄像头状态
        captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        var layer = previewView.layer
        layer.masksToBounds = true
        
        captureVideoPreviewLayer!.frame=layer.bounds;
        captureVideoPreviewLayer!.videoGravity=AVLayerVideoGravityResizeAspectFill;//填充模式
        //将视频预览层添加到界面中
        layer.insertSublayer(captureVideoPreviewLayer!, below: focusCusor.layer)
        
        enableRotation = false
        addNotificationToCaptureDevice(captureDevice!)
        addGenstureRecognizer()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        captureSession!.startRunning()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession!.stopRunning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func getCameraDeviceWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let cameras: [AnyObject] = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for camera in cameras {
            var theCamera = camera as AVCaptureDevice
            if theCamera.position == position {
                return theCamera
            }
        }
        
        return nil
    }
    
    func changeDeviceProperty(propertyChange: PropertyChangeBlock) {
        var captureDevice = captureDeviceInput!.device
        var error: NSError? = nil
        //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
        if (captureDevice.lockForConfiguration(&error)) {
            propertyChange(captureDevice)
            captureDevice.unlockForConfiguration()
        } else {
            println("设置设备属性过程发生错误，错误信息：\(error?.localizedDescription)")
        }
    }
    
    func setFocusCursorWithPoint(point: CGPoint) {
        focusCusor.center = point
        focusCusor.transform = CGAffineTransformMakeScale(1.5, 1.5)
        focusCusor.alpha = 1.0
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.focusCusor.transform = CGAffineTransformIdentity
            }) { (finished: Bool) -> Void in
            self.focusCusor.alpha = 0
        }
    }
    
    func focusWithMode(focusMode: AVCaptureFocusMode, witExposureMode exposureMode:AVCaptureExposureMode, atPoint point:CGPoint) {
        changeDeviceProperty { (device: AVCaptureDevice) -> () in
            if device.isFocusModeSupported(focusMode) {
                device.focusMode = .AutoFocus
            }
            
            if device.focusPointOfInterestSupported {
                device.focusPointOfInterest = point
            }
            
            if device.isExposureModeSupported(exposureMode) {
                device.exposureMode = .AutoExpose
            }
            
            if device.exposurePointOfInterestSupported {
                device.exposurePointOfInterest = point
            }
        }
    }
    
    func startRecord() {
        //根据设备输出获得连接
        var captureConnection = captureMovieFileOutput!.connectionWithMediaType(AVMediaTypeVideo)
        //根据连接取得设备输出的数据
        if (!captureMovieFileOutput!.recording) {

            //如果支持多任务则则开始多任务
            if UIDevice.currentDevice().multitaskingSupported {
                backgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
                    
                })
            }
            //预览图层和视频方向保持一致
            captureConnection.videoOrientation=captureVideoPreviewLayer!.connection.videoOrientation;
            var outputFielPath = NSTemporaryDirectory().stringByAppendingString("myMovie.mp4")
            println("save path is : \(outputFielPath)");
            var fileUrl = NSURL(fileURLWithPath: outputFielPath)
            println("fileUrl : \(fileUrl)");
            captureMovieFileOutput!.startRecordingToOutputFileURL(fileUrl, recordingDelegate: self)
        }
        else{
            println("错误：正在录制视频")
        }
    }
    
    func stopRecordAndSave(saveOrNot: Bool) {
        captureMovieFileOutput!.stopRecording()
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
    
    // MARK: - notifications
    func addNotificationToCaptureDevice(captureDevice: AVCaptureDevice) {
        //注意添加区域改变捕获通知必须首先设置设备允许捕获
        changeDeviceProperty { (device: AVCaptureDevice) -> () in
            device.subjectAreaChangeMonitoringEnabled = true
        }
        //捕获区域发生改变
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "areaChange:", name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: captureDevice)
    }
    
    func areaChange(notification: NSNotification) {
        println("捕获区域改变...")
    }
    
    func addNotificationToCaptureSession(captureSession: AVCaptureSession) {
        //会话出错
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sessionRuntimeError:", name: AVCaptureSessionRuntimeErrorNotification, object: captureSession)
    }
    
    func sessionRuntimeError(notification: NSNotification) {
        println("会话发生错误")
    }
    
    func removeNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - gestures
    func addGenstureRecognizer() {
        var tap = UITapGestureRecognizer(target: self, action: "tapScreen:")
        previewView.addGestureRecognizer(tap)
    }
    
    func tapScreen(tap: UITapGestureRecognizer) {
        var point = tap.locationInView(previewView)
        //将UI坐标转化为摄像头坐标
        var cameraPoint = captureVideoPreviewLayer!.captureDevicePointOfInterestForPoint(point)
        setFocusCursorWithPoint(point)
        focusWithMode(.AutoFocus, witExposureMode: .AutoExpose, atPoint: cameraPoint)
    }

    // MARK: - 
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        println("开始录制...")
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        println("录制完成...")
        if saveToDisk {
            //视频录入完成之后在后台将视频存储到相簿
            let lastBackgroundTaskIdentifier = self.backgroundTaskIdentifier
            let assetsLibrary = ALAssetsLibrary()
            assetsLibrary.writeVideoAtPathToSavedPhotosAlbum(outputFileURL, completionBlock: { (url: NSURL?, error: NSError?) -> Void in
                if error != nil {
                    println("保存视频到相簿过程中发生错误，错误信息：\(error!.localizedDescription)")
                }
                println("outputUrl: \(outputFileURL)")
                NSFileManager.defaultManager().removeItemAtURL(outputFileURL, error: nil)
                if lastBackgroundTaskIdentifier != UIBackgroundTaskInvalid {
                    UIApplication.sharedApplication().endBackgroundTask(lastBackgroundTaskIdentifier!)
                }
                println("成功保存视频到相簿.")
            })
        }
    }
}
