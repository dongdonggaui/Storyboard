//
//  AddNewAlbumViewController.swift
//  Storyboard
//
//  Created by huangluyang on 15/6/1.
//  Copyright (c) 2015年 HLY. All rights reserved.
//

import UIKit

class AddNewAlbumViewController: UIViewController, UIScrollViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var viewModel: AddNewAlbumViewModel?
    var _scrollView: UIScrollView? = nil
    var _scrollContentView: UIView? = nil
    var _titleTextField: UITextField? = nil
    var _datePickerButton: UIButton? = nil
    var _datePicker: UIDatePicker? = nil
    var _imagePickerButton: UIButton? = nil
    var _imageView: UIImageView? = nil
    
    var pickerIsShowing = false
    let datePickerHeight: CGFloat = 216
    var datePickerBottomConstraint: NSLayoutConstraint?
    
    var hasSetupConstraints = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        if let vm = viewModel {
            RAC(vm, "title").assignSignal(titleTextField.rac_textSignal())
            var dateSignal = RACObserve(vm, "date")
            RAC(vm, "date").assignSignal(datePicker.rac_newDateChannelWithNilValue(nil))
            dateSignal.subscribeNext({ (obj) -> Void in
                if let date = obj as? NSDate {
                    self.datePickerButton.setTitle(date.descriptionWithLocale(NSLocale.currentLocale()), forState: .Normal)
                } else {
                    self.datePickerButton.setTitle("选取日期", forState: .Normal)
                }
            })
            var imageSignal = RACObserve(vm, "image")
            RAC(imageView, "image").assignSignal(imageSignal)
            RAC(navigationItem.rightBarButtonItem!, "enabled").assignSignal(RACObserve(vm, "canSubmit"))
        }
    }
    
    override func updateViewConstraints() {
        if !hasSetupConstraints {
            scrollView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
            
            scrollContentView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
            scrollContentView.autoMatchDimension(.Width, toDimension: .Width, ofView: view)
            
            titleTextField.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(10, 10, 10, 10), excludingEdge: .Bottom)
            titleTextField.autoSetDimension(.Height, toSize: 21)
            
            datePickerButton.autoPinEdge(.Left, toEdge: .Left, ofView: titleTextField)
            datePickerButton.autoPinEdge(.Right, toEdge: .Right, ofView: titleTextField)
            datePickerButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleTextField, withOffset: 8)
            datePickerButton.autoSetDimension(.Height, toSize: 30)
            
            imagePickerButton.autoPinEdge(.Left, toEdge: .Left, ofView: titleTextField)
            imagePickerButton.autoPinEdge(.Right, toEdge: .Right, ofView: titleTextField)
            imagePickerButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: datePickerButton, withOffset: 8)
            imagePickerButton.autoSetDimension(.Height, toSize: 30)
            
            imageView.autoPinEdge(.Left, toEdge: .Left, ofView: titleTextField)
            imageView.autoPinEdge(.Right, toEdge: .Right, ofView: titleTextField)
            imageView.autoPinEdge(.Top, toEdge: .Bottom, ofView: imagePickerButton, withOffset: 8)
            imageView.autoMatchDimension(.Height, toDimension: .Width, ofView: imageView, withMultiplier: 0.75)
            imageView.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: scrollContentView)
            
            datePicker.autoPinEdgeToSuperviewEdge(.Left)
            datePicker.autoPinEdgeToSuperviewEdge(.Right)
            datePicker.autoSetDimension(.Height, toSize: datePickerHeight)
            datePickerBottomConstraint = datePicker.autoPinEdgeToSuperviewEdge(.Bottom, withInset: -datePickerHeight)
            
            hasSetupConstraints = true
        }
        super.updateViewConstraints()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ScrollViewDelegate
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if pickerIsShowing {
            dismissDatePicker()
        }
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(actionSheet: UIActionSheet, willDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex == actionSheet.cancelButtonIndex {
            return
        }
        var ipc = UIImagePickerController()
        ipc.delegate = self
        if 1 == buttonIndex {
            ipc.sourceType = .PhotoLibrary
            presentViewController(ipc, animated: true, completion: nil)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        viewModel!.image = image
        imageView.image = image
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Event Response
    func datePickerTapped() {
        if pickerIsShowing {
            return
        }
        pickerIsShowing = true
        datePickerBottomConstraint?.constant = 0
        view.setNeedsUpdateConstraints()
        view.updateConstraintsIfNeeded()
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func imagePickerTapped() {
        var actionSheet = UIActionSheet(title: "请选择", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "从相册选择", "拍照")
        actionSheet.showInView(view)
    }
    
    func didSingleTapped(tap: UITapGestureRecognizer) {
        if tap.state == .Ended {
            dismissDatePicker()
        }
    }
    
    func dismissViewController() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addAlbum() {
        viewModel!.insertNewObject()
    }

    // MARK: - Private
    func setupUI() {
        let tap = UITapGestureRecognizer(target: self, action: "didSingleTapped:")
        view.addGestureRecognizer(tap)
        view.addSubview(scrollView)
        view.addSubview(datePicker)
        
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(titleTextField)
        scrollContentView.addSubview(datePickerButton)
        scrollContentView.addSubview(imagePickerButton)
        scrollContentView.addSubview(imageView)
        
        var cancelItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "dismissViewController")
        navigationItem.leftBarButtonItem = cancelItem
        var addItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "addAlbum")
        navigationItem.rightBarButtonItem = addItem
    }
    
    func dismissDatePicker() {
        datePickerBottomConstraint?.constant = datePickerHeight
        view.setNeedsUpdateConstraints()
        view.updateConstraintsIfNeeded()
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) { (finished) -> Void in
            self.pickerIsShowing = !finished
        }
    }
    
    // MARK: - Setters & Getters
    var scrollView: UIScrollView {
        if _scrollView != nil {
            return _scrollView!
        }
        _scrollView = UIScrollView()
        _scrollView!.alwaysBounceVertical = true
        _scrollView!.delegate = self
        return _scrollView!
    }
    var scrollContentView: UIView {
        if _scrollContentView != nil {
            return _scrollContentView!
        }
        _scrollContentView = UIView()
        return _scrollContentView!
    }
    var titleTextField: UITextField {
        if _titleTextField != nil {
            return _titleTextField!
        }
        _titleTextField = UITextField()
        _titleTextField!.placeholder = "请输入标题（1-18个字符）"
        _titleTextField!.textAlignment = .Center
        return _titleTextField!
    }
    var datePickerButton: UIButton {
        if _datePickerButton != nil {
            return _datePickerButton!
        }
        _datePickerButton = UIButton()
        _datePickerButton!.setTitle("选取日期", forState: .Normal)
        _datePickerButton!.setTitleColor(UIColor.orangeColor(), forState: .Normal)
        _datePickerButton!.addTarget(self, action: "datePickerTapped", forControlEvents: .TouchUpInside)
        return _datePickerButton!
    }
    var datePicker: UIDatePicker {
        if _datePicker != nil {
            return _datePicker!
        }
        _datePicker = UIDatePicker()
        _datePicker!.datePickerMode = .Date
        return _datePicker!
    }
    var imagePickerButton: UIButton {
        if _imagePickerButton != nil {
            return _imagePickerButton!
        }
        _imagePickerButton = UIButton()
        _imagePickerButton!.setTitle("选取照片", forState: .Normal)
        _imagePickerButton!.setTitleColor(UIColor.orangeColor(), forState: .Normal)
        _imagePickerButton!.addTarget(self, action: "imagePickerTapped", forControlEvents: .TouchUpInside)
        return _imagePickerButton!
    }
    var imageView: UIImageView {
        if _imageView != nil {
            return _imageView!
        }
        _imageView = UIImageView()
        _imageView!.image = UIImage(color: UIColor.orangeColor())
        _imageView!.contentMode = .ScaleAspectFill
        _imageView!.clipsToBounds = true
        return _imageView!
    }
}
