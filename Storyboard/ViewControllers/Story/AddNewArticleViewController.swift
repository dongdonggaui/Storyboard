//
//  AddNewStoryViewController.swift
//  Storyboard
//
//  Created by huangluyang on 15/6/5.
//  Copyright (c) 2015年 HLY. All rights reserved.
//

import UIKit

class AddNewArticleViewController: UIViewController {

    private var hasSetupConstraints = false
    var viewModel: AddNewArticleViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        if let vm = viewModel {
            RAC(vm, "title").assignSignal(self.textField.rac_textSignal())
            RAC(vm, "content").assignSignal(self.textView.rac_textSignal())
            RAC(self.navigationItem.rightBarButtonItem!, "enabled").assignSignal(RACSignal.combineLatest([RACObserve(vm, "title"), RACObserve(vm, "content")], reduce: { () -> AnyObject! in
                return (self.viewModel?.title as NSString?)?.length > 0 && (self.viewModel?.content as NSString?)?.length > 0
            }))
        }
    }
    
    override func updateViewConstraints() {
        if !self.hasSetupConstraints {
            self.textField.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(72, 10, 8, 10), excludingEdge: .Bottom)
            self.textField.autoSetDimension(.Height, toSize: 21)
            self.textView.autoPinEdge(.Left, toEdge: .Left, ofView: self.textField)
            self.textView.autoPinEdge(.Right, toEdge: .Right, ofView: self.textField)
            self.textView.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.textField, withOffset:8)
            self.textView.autoSetDimension(.Height, toSize: 100)
            self.hasSetupConstraints = true
        }
        super.updateViewConstraints()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Event Response
    func cancel() {
        self.viewModel!.cancel()
        self.dismissSelf()
    }
    
    func done() {
        self.dismissSelf()
    }
    
    // MARK: - Private
    private func setupUI() {
        self.title = "写日记"
        var cancelItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel")
        self.navigationItem.leftBarButtonItem = cancelItem
        var doneItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done")
        self.navigationItem.rightBarButtonItem = doneItem
        
        self.view.addSubview(self.textField)
        self.view.addSubview(self.textView)
    }
    
    func dismissSelf() {
        self.viewModel!.willDismiss()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Getters
    private var _textField: UITextField?
    private var _textView: UITextView?
    
    var textField: UITextField {
        if _textField == nil {
            _textField = UITextField()
            _textField!.backgroundColor = UIColor.orangeColor()
        }
        return _textField!
    }
    
    var textView: UITextView {
        if _textView == nil {
            _textView = UITextView()
            _textView!.backgroundColor = UIColor.orangeColor()
        }
        return _textView!
    }
}
