//
//  ViewController.swift
//  CPKeyboardStateObserver
//
//  Created by ベックマンラモン on 2016/02/02.
//  Copyright © 2016年 Corepilots. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CPKeyboardObserverDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var functionButton: UIButton!
    @IBOutlet weak var stateLabelBottomConstraint: NSLayoutConstraint!
    
    var blockForStateHide: BlockForState!
    var blockForStateShow: BlockForState!
    var blockForStateUndockEvent: BlockForState!
    var blockForStateDockEvent: BlockForState!
    var blockForStateWillMove: BlockForState!
    var blockForStateDidMove: BlockForState!
    
    var mode: ObservationMode!
    
    var observationModeStringArray = ["delegate", "block"]
    
    enum ObservationMode: Int {
        case Block
        case Delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // we start with using blocks
        self.mode = .Block
        
        self.initData()
        
        // init the views
        self.initViews()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        CPKeyboardStateObserver.sharedObserver.startObserving(self.view, blockForStateHide: self.blockForStateHide, blockForStateShow: self.blockForStateShow, blockForStateUndock: self.blockForStateUndockEvent, blockForStateDock: self.blockForStateDockEvent, blockForStateWillMove: self.blockForStateWillMove, blockForStateDidMove: self.blockForStateDidMove)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        CPKeyboardStateObserver.sharedObserver.stopObserving()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    private func initData() {
        
        self.blockForStateHide = { (keyboardInfo: [NSObject : AnyObject]) -> Void in
            self.stateLabel.text = "blockDidHide"
            self.moveLabel(keyboardInfo, shouldFollowKeyboard: true)
        }
        
        self.blockForStateShow = { (keyboardInfo: [NSObject : AnyObject]) -> Void in
            self.stateLabel.text = "blockDidShow"
            self.moveLabel(keyboardInfo, shouldFollowKeyboard: true)
        }
        
        self.blockForStateUndockEvent = { (keyboardInfo: [NSObject : AnyObject]) -> Void in
            self.stateLabel.text = "blockDidUndock"
            self.moveLabel(keyboardInfo, shouldFollowKeyboard: true)
        }
        
        self.blockForStateDockEvent = { (keyboardInfo: [NSObject : AnyObject]) -> Void in
            self.stateLabel.text = "blockDidDock"
            self.moveLabel(keyboardInfo, shouldFollowKeyboard: true)
        }
        
        self.blockForStateWillMove = { (keyboardInfo: [NSObject : AnyObject]) -> Void in
            self.stateLabel.text = "blockWillMove"
//            self.moveLabel(keyboardInfo, shouldFollowKeyboard: true)
            self.hideLabel()
        }
        
        self.blockForStateDidMove = { (keyboardInfo: [NSObject : AnyObject]) -> Void in
            self.stateLabel.text = "blockDidMove"
            self.moveLabel(keyboardInfo, shouldFollowKeyboard: true)
        }
    }
    
    
    private func initViews() {
        
        self.functionButton.setTitle(self.observationModeStringArray[self.mode.rawValue], forState: .Normal)
        self.pauseButton.setTitle("pause", forState: .Normal)
    }
    
    
    @IBAction func toggleMode(sender: UIButton) {
        
        let sharedObserver = CPKeyboardStateObserver.sharedObserver
        sharedObserver.stopObserving()
        
        if self.mode == .Block {
            sharedObserver.startObserving(self.view, delegate: self)
            self.mode = .Delegate
            sender.setTitle("block", forState: .Normal)
        }
        else {
            CPKeyboardStateObserver.sharedObserver.startObserving(self.view, blockForStateHide: self.blockForStateHide, blockForStateShow: self.blockForStateShow, blockForStateUndock: self.blockForStateUndockEvent, blockForStateDock: self.blockForStateDockEvent, blockForStateWillMove: self.blockForStateWillMove, blockForStateDidMove: self.blockForStateDidMove)
            
            self.mode = .Block
            sender.setTitle("delegate", forState:.Normal)
        }
    }
    
    
    private func moveLabel(userInfo: [NSObject : AnyObject], shouldFollowKeyboard: Bool) {
        
        let keyboardFrame = (userInfo[KeyboardFrameDictionaryKey.CPKeyboardStateObserverNewFrameKey] as! NSValue).CGRectValue()
        
//        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
        NSLog("keyboard.origin.y %@", NSStringFromCGRect(keyboardFrame))
        NSLog("screen height %f keyboardframey %f state label height %f", UIScreen.mainScreen().bounds.size.height, keyboardFrame.origin.y, self.stateLabel.frame.size.height)
        NSLog("move label to %f", (UIScreen.mainScreen().bounds.size.height - keyboardFrame.origin.y) + self.stateLabel.frame.size.height)
        if shouldFollowKeyboard {
            self.stateLabelBottomConstraint.constant = (UIScreen.mainScreen().bounds.size.height - keyboardFrame.origin.y) + self.stateLabel.frame.size.height
        }
        else {
            self.stateLabelBottomConstraint.constant = UIScreen.mainScreen().bounds.size.height
        }
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
//            self.stateLabel.setNeedsDisplay()
            self.view.layoutIfNeeded()
            }, completion: { (Bool) -> Void in
                self.showLabel()
            })
        
//            }, completion: nil)
    }
    
    @IBAction func toggleAction(sender: UIButton) {
        
        let keyboardObserver = CPKeyboardStateObserver.sharedObserver
        
        if keyboardObserver.isObserving {
            keyboardObserver.pauseObserver()
            sender.setTitle("play", forState: .Normal)
            self.stateLabel.text = "pause"
        }
        else {
            keyboardObserver.restartObserver()
            sender.setTitle("pause", forState: .Normal)
            self.stateLabel.text = "play"
        }
    }
    
    private func showLabel() {
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.stateLabel.alpha = 1
            }, completion: nil)
    }
    
    private func hideLabel() {
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.stateLabel.alpha = 0
            }, completion: nil)
    }
    
    /*
    - (IBAction)toggleAction:(id)sender
    {
    UIButton *button = (UIButton *)sender;
    
    HPSKeyboardStateObserver *keyboardStateObserver = [HPSKeyboardStateObserver sharedObserver];
    
    if(keyboardStateObserver.isObserving){
    [keyboardStateObserver pauseObserver];
    [button setTitle:@"play" forState:UIControlStateNormal];
    self.stateLabel.text = @"pause";
    }
    else{
    [keyboardStateObserver restartObserver];
    [button setTitle:@"pause" forState:UIControlStateNormal];
    self.stateLabel.text = @"play";
    }
    }
    */
    
    // MARK: CPKeyboardStateObserverDelegate methods
    
    func keyboardDidMove(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject]) {
        self.stateLabel.text = "delegateDidMove"
        self.moveLabel(keyboardInfo, shouldFollowKeyboard: true)
    }
    
    func keyboardWillDock(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject]) {
        self.stateLabel.text = "delegateDidDock"
        self.moveLabel(keyboardInfo, shouldFollowKeyboard: true)
    }
    
    func keyboardWillHide(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject]) {
        self.stateLabel.text = "delegateDidHide"
        self.moveLabel(keyboardInfo, shouldFollowKeyboard: true)
    }
    
    func keyboardWillMove(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject]) {
        self.stateLabel.text = "delegateWillMove"
//        self.moveLabel(keyboardInfo, shouldFollowKeyboard: true)
        self.hideLabel()
    }
    
    func keyboardWillShow(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject]) {
        self.stateLabel.text = "delegateDidShow"
        self.moveLabel(keyboardInfo, shouldFollowKeyboard: true)
    }
    
    func keyboardWillUndock(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject]) {
        self.stateLabel.text = "delegateDidUndock"
        self.moveLabel(keyboardInfo, shouldFollowKeyboard: true)
    }
}