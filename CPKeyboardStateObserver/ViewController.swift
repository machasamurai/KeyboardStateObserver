//
//  ViewController.swift
//  CPKeyboardStateObserver
//
//  Created by Ramon Beckmann on 2016/02/02.
//  Copyright © 2016 Corepilots. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CPKeyboardObserverDelegate {
    
    // textView used to trigger the keyboard events
    @IBOutlet weak var textView: UITextView!
    // label that displays the current keyboards state and the callback method
    @IBOutlet weak var stateLabel: UILabel!
    // // button to pause the observer
    @IBOutlet weak var pauseButton: UIButton!
    // button to change the callback methos (delegate or closure (block))
    @IBOutlet weak var functionButton: UIButton!
    // constraint used to animate the label
    @IBOutlet weak var stateLabelBottomConstraint: NSLayoutConstraint!
    
    // blocks used to demonstrate the observer using closures
    var blockForStateHide: BlockForState!
    var blockForStateShow: BlockForState!
    var blockForStateUndockEvent: BlockForState!
    var blockForStateDockEvent: BlockForState!
    var blockForStateWillMove: BlockForState!
    var blockForStateDidMove: BlockForState!
    // the current observation mode
    var mode: ObservationMode!
    
    var observationModeStringArray = ["delegate", "block"]
    
    /**
     The observation modes.
     
     - Block: use the observer using blocks/closures as callback method.
     - Delegate: use the observer using the CPKeyboardObserverDelegate
     */
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
        
        // start the observer using blocks/closures
        CPKeyboardStateObserver.sharedObserver.startObserving(self.view, blockForStateHide: self.blockForStateHide, blockForStateShow: self.blockForStateShow, blockForStateUndock: self.blockForStateUndockEvent, blockForStateDock: self.blockForStateDockEvent, blockForStateWillMove: self.blockForStateWillMove, blockForStateDidMove: self.blockForStateDidMove)
    
        CPKeyboardStateObserver.sharedObserver.startObserving(self.view, blockForStateHide: { (keyboardInfo) -> Void in
            print("keyboard is hidden")
            }, blockForStateShow: { (keyboardInfo) -> Void in
                print("keyboard is shown")
            }, blockForStateUndock: { (keyboardInfo) -> Void in
                print("keyboard is detached")
            }, blockForStateDock: { (keyboardInfo) -> Void in
                print("keyboard is docked")
            }, blockForStateWillMove: { (keyboardInfo) -> Void in
                print("keyboard will move")
            }, blockForStateDidMove: { (keyboardInfo) -> Void in
                print("keyboard did move")
        })
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // stop observing since the viewController will disappear
        CPKeyboardStateObserver.sharedObserver.stopObserving()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
     Initialize the blocks for the observer.
     For the demo purpose we just change the text of the state label to the corresponding event and move the state label along with the keyboard frame for all events except the 'willMove' event.
     */
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
            self.hideLabel()
        }
        
        self.blockForStateDidMove = { (keyboardInfo: [NSObject : AnyObject]) -> Void in
            self.stateLabel.text = "blockDidMove"
            self.moveLabel(keyboardInfo, shouldFollowKeyboard: true)
        }
    }
    
    /**
     Initialize the views.
     For the demo purposes we only set the button titles.
     */
    private func initViews() {
        
        self.functionButton.setTitle(self.observationModeStringArray[self.mode.rawValue], forState: .Normal)
        self.pauseButton.setTitle("pause", forState: .Normal)
    }
    
    /**
     Toggle the observation mode.
     Toggle between delegate mode and block/closure mode.
     
     - Parameter sender: the function button.
     */
    @IBAction func toggleMode(sender: UIButton) {
        
        let sharedObserver = CPKeyboardStateObserver.sharedObserver
        // stop observing before changing the observing mode
        sharedObserver.stopObserving()
        
        // if currently using blocks/closures switch to using the delegate
        if self.mode == .Block {
            sharedObserver.startObserving(self.view, delegate: self)
            self.mode = .Delegate
            sender.setTitle("block", forState: .Normal)
        }
        // if currently using the delegate switch to using blocks/closures
        else {
            CPKeyboardStateObserver.sharedObserver.startObserving(self.view, blockForStateHide: self.blockForStateHide, blockForStateShow: self.blockForStateShow, blockForStateUndock: self.blockForStateUndockEvent, blockForStateDock: self.blockForStateDockEvent, blockForStateWillMove: self.blockForStateWillMove, blockForStateDidMove: self.blockForStateDidMove)
            
            self.mode = .Block
            sender.setTitle("delegate", forState:.Normal)
        }
    }
    
    /**
     Move the label with the information from the new keyboard frame dictionary.
     
     - Parameter userInfo: the dictionary with the information about the keyboard frame.
     - Parameter shouldFollowKeyboard: boolean that indicates if the label should follow the keyboard.
        true = follow
        false = don't follow
     */
    private func moveLabel(userInfo: [NSObject : AnyObject], shouldFollowKeyboard: Bool) {
        
        let keyboardFrame = (userInfo[KeyboardFrameDictionaryKey.CPKeyboardStateObserverNewFrameKey] as! NSValue).CGRectValue()
        
        if shouldFollowKeyboard {
            self.stateLabelBottomConstraint.constant = (UIScreen.mainScreen().bounds.size.height - keyboardFrame.origin.y) + self.stateLabel.frame.size.height
        }
        else {
            self.stateLabelBottomConstraint.constant = UIScreen.mainScreen().bounds.size.height
        }
        
        // since we are using the storyboard and constraints we use 'layoutIfNeeded' to animate the tranlation
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: { (Bool) -> Void in
                // show the label if hidden
                self.showLabel()
            })
    }
    
    /**
     Pause and restart the observer.
     
     - Parameter sender: the action button.
     */
    @IBAction func toggleAction(sender: UIButton) {
        
        let keyboardObserver = CPKeyboardStateObserver.sharedObserver
        
        // if is observing pause the observer
        if keyboardObserver.isObserving {
            keyboardObserver.pauseObserver()
            sender.setTitle("play", forState: .Normal)
            self.stateLabel.text = "pause"
        }
        // if obsevrer is paused restart it
        else {
            keyboardObserver.restartObserver()
            sender.setTitle("pause", forState: .Normal)
            self.stateLabel.text = "play"
        }
    }
    
    /**
     Shows the label with an alpha animation.
     */
    private func showLabel() {
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.stateLabel.alpha = 1
            }, completion: nil)
    }
    
    /**
     Hides the label with an alpha animation.
     */
    private func hideLabel() {
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.stateLabel.alpha = 0
            }, completion: nil)
    }
    
    
    // MARK: CPKeyboardStateObserverDelegate methods
    
    /**
    The keyboard didMove event.
    We change the label text and label position.
    
    - Parameter keyboardStateObserver: the observer instance.
    - Parameter keyboardInfo: the dictionary with the information about the keyboard frame.
    */
    func keyboardDidMove(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject]) {
        self.stateLabel.text = "delegateDidMove"
        self.moveLabel(keyboardInfo, shouldFollowKeyboard: true)
    }
    
    /**
     The keyboard willDock event.
     We change the label text and label position.
     
     - Parameter keyboardStateObserver: the observer instance.
     - Parameter keyboardInfo: the dictionary with the information about the keyboard frame.
     */
    func keyboardWillDock(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject]) {
        self.stateLabel.text = "delegateDidDock"
        self.moveLabel(keyboardInfo, shouldFollowKeyboard: true)
    }
    
    /**
     The keyboard willHide event.
     We change the label text and label position.
     
     - Parameter keyboardStateObserver: the observer instance.
     - Parameter keyboardInfo: the dictionary with the information about the keyboard frame.
     */
    func keyboardWillHide(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject]) {
        self.stateLabel.text = "delegateDidHide"
        self.moveLabel(keyboardInfo, shouldFollowKeyboard: true)
    }
    
    /**
     The keyboard willMove event.
     We change the label text and hide the label.
     
     - Parameter keyboardStateObserver: the observer instance.
     - Parameter keyboardInfo: the dictionary with the information about the keyboard frame.
     */
    func keyboardWillMove(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject]) {
        self.stateLabel.text = "delegateWillMove"
        self.hideLabel()
    }
    
    /**
     The keyboard willShow event.
     We change the label text and label position.
     
     - Parameter keyboardStateObserver: the observer instance.
     - Parameter keyboardInfo: the dictionary with the information about the keyboard frame.
     */
    func keyboardWillShow(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject]) {
        self.stateLabel.text = "delegateDidShow"
        self.moveLabel(keyboardInfo, shouldFollowKeyboard: true)
    }
    
    /**
     The keyboard willUndock event.
     We change the label text and label position.
     
     - Parameter keyboardStateObserver: the observer instance.
     - Parameter keyboardInfo: the dictionary with the information about the keyboard frame.
     */
    func keyboardWillUndock(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject]) {
        self.stateLabel.text = "delegateDidUndock"
        self.moveLabel(keyboardInfo, shouldFollowKeyboard: true)
    }
}