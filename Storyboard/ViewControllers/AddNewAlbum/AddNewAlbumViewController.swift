//
//  AddNewAlbumViewController.swift
//  Storyboard
//
//  Created by huangluyang on 15/6/1.
//  Copyright (c) 2015年 HLY. All rights reserved.
//

import UIKit

class AddNewAlbumViewController: UIViewController {
    
    var viewModel: AddNewAlbumViewModel?
    let scrollView = UIScrollView()
    let scrollContentView = UIView()
    let titleTextField = UITextField()
    let datePickerButton = UIButton()
    let imagePickerButton = UIButton()
    let imageView = UIImageView()
    
    var hasSetupConstraints = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(titleTextField)
        scrollContentView.addSubview(datePickerButton)
        scrollContentView.addSubview(imagePickerButton)
        scrollContentView.addSubview(imageView)
        scrollView.alwaysBounceVertical = true
        
        if let vm = viewModel {
//            RAC(vm, title) =
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
            
            hasSetupConstraints = true
        }
        super.updateViewConstraints()
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

}
