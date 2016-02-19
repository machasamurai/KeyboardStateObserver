//
//  CPKeyboardStateObserver.swift
//  CPKeyboardStateObserver
//
//  Created by ベックマンラモン on 2016/02/02.
//  Copyright © 2016年 Corepilots. All rights reserved.
//

import Foundation
import UIKit

typealias BlockForState = (keyboardInfo: [NSObject : AnyObject]) -> Void

protocol CPKeyboardObserverDelegate: class {
    
    /// 'Keyboard will hide' event.
    /// @param  CPKeyboardStateObserver instance.
    /// @param  Dictionary that contains the keyboard frame values.
    func keyboardWillHide(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject])
    
    /// 'Keyboard will show' event.
    /// @param  CPKeyboardStateObserver instance.
    /// @param  Dictionary that contains the keyboard frame values.
    func keyboardWillShow(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject])
    
    /// 'Keyboard will undock' event. The keyboard detaches from the bottom of the screen.
    /// @param  CPKeyboardStateObserver instance.
    /// @param  Dictionary that contains the keyboard frame values.
    func keyboardWillUndock(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject])
    
    /// 'Keyboard will dock event. The keyboard attaches to the bottom of the screen.
    /// @param  CPKeyboardStateObserver instance.
    /// @param  Dictionary that contains the keyboard frame values.
    func keyboardWillDock(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject])
    
    /// 'Keyboard will move' event. The keyboard will be moved by the user while being detached from the bottom of the screen.
    /// @param  CPKeyboardStateObserver instance.
    /// @param  Dictionary that contains the keyboard frame values.
    func keyboardWillMove(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject])
    
    /// 'Keyboard did move' event. The keyboard was moved by the user while being detached from the bottom of the screen.
    /// @param  CPKeyboardStateObserver instance.
    /// @param  Dictionary that contains the keyboard frame values.
    func keyboardDidMove(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject])
}

struct KeyboardFrameDictionaryKey {
    static let Begin                                        = "UIKeyboardFrameBeginUserInfoKey"
    static let End                                          = "UIKeyboardFrameEndUserInfoKey"
    static let AnimationDuration                            = "UIKeyboardAnimationDurationUserInfoKey"
    static let CPKeyboardStateObserverNewFrameKey           = "HPSKeyboardStateObserverNewKeyboardFrameKey"
    static let CPKeyboardStateObserverOriginalKeyboardFrame = "HPSKeyboardStateObserverOriginalKeyboardFrameKey"
}

class CPKeyboardStateObserver: NSObject {
    // singleton instance
    static let sharedObserver = CPKeyboardStateObserver()
    
    // callback delegate
    private var delegate: CPKeyboardObserverDelegate!
    
    // callback blocks
    private var blockForStateHide: BlockForState!
    var blockForStateShow: BlockForState!
    var blockForStateUndock: BlockForState!
    var blockForStateDock: BlockForState!
    var blockForStateWillMove: BlockForState!
    var blockForStateDidMove: BlockForState!
    
    // current state the keyboard is in
    var currentKeyboardState: KeyboardObserverState!
    // the previous state the keyboard was in
    var previousKeyboardState: KeyboardObserverState!
    
    // helper variables to determine the next state
    private var hasKeyboardJustUndocked: Bool = false
    private var hasKeyboardJustDocked: Bool = false
    
    // true when is observing, false when is stopped or paused
    private var isObserving: Bool = false
    
    let keyboardAnimationTime = 0.5
    
    // definitions struct to calculate the next keyboard state
    struct KeyboardStateDefinition {
        
        static var isKeyboardAtBottom: Bool?
        static var isKeyboardDetached: Bool?
        static var isKeyboardHidden: Bool?
        static var isKeyboardVisible: Bool?
        
        
        static func calculateKeyboardPosition(userInfo: [NSObject : AnyObject]) {
            
            guard let endFrame: CGRect = userInfo[KeyboardFrameDictionaryKey.End]?.CGRectValue else {
                return
            }
            
            let keyboardY = endFrame.origin.y
            let keyboardHeight = endFrame.size.height
            
            let screenHeight = UIScreen.mainScreen().bounds.size.height
            
            isKeyboardAtBottom = keyboardY == (screenHeight - keyboardHeight)
            isKeyboardDetached = (keyboardY + keyboardHeight) < screenHeight
            isKeyboardHidden = keyboardY == screenHeight
            isKeyboardVisible = keyboardY < screenHeight
        }
        
        static func isDataValid() -> Bool {
            return (isKeyboardAtBottom != nil && isKeyboardDetached != nil && isKeyboardHidden != nil && isKeyboardVisible != nil)
        }
        
        static func printState() {
            print("bottom: \(isKeyboardAtBottom!)\ndetached: \(isKeyboardDetached!)\nhidden: \(isKeyboardHidden!)\nvisible: \(isKeyboardVisible!)")
        }
    }
    
    /**
     The supported keyboard states.
    
     - Hidden: the keyboard is not visible.
     - ShownDocked: the keyboard is visible and docked at the bottom of the screen.
     - ShownUndocked: the keyboard is visible and detached from the screen bottom.
     - HiddenUndocked: the keyboard is not visible and detached from the screen bottom.
     - ShownSplit: the keyboard is visible and split while being detached from the screen bottom.
     - HiddenSplit: the keyboard is not visible and split while being detached from the screen bottom (when visible)
     */
    enum KeyboardObserverState: Int {
        case Hidden
        case ShownDocked
        case ShownUndocked
        case HiddenUndocked
        case ShownSplit
        case HiddenSplit
    }
    
    /**
     Caller definitions for the NSNotification events when the keyboard state changes.
     
     - KeyboardObserverCallerWillChange: the keyboard frame will change event caller.
     - KeyboardObserverCallerDidChange: the keyboard frame did change event caller.
     */
    enum KeyboardObserverCaller: Int {
        case KeyboardObserverCallerWillChange
        case KeyboardObserverCallerDidChange
    }
    
    /**
     Start observing using blocks.
     
     - Parameters: 
        - view: the view of the UIViewController that starts the observer. Used to hide the keyboard.
        - blockForStateHide: code block that gets executed when the keyboard hides.
        - blockForStateShow: code block that gets executed when the keyboard shows up.
        - blockForStateUndock: code block that gets executed when the keyboard detaches from the screen bottom.
        - blockForStateDock: code block that gets executed when the keyboard returns to the screen bottom.
        - blockForStateWillMove: code block that gets executed when the keyboard keyboard starts to move/split/merge while being detached.
        - blockForStateDidMove: code block that gets executed when the keyboard keyboard did move/split/merge while being detached.
     */
    func startObserving(view: UIView, blockForStateHide: BlockForState, blockForStateShow: BlockForState, blockForStateUndock: BlockForState, blockForStateDock: BlockForState, blockForStateWillMove: BlockForState, blockForStateDidMove: BlockForState) {
        
        self.blockForStateHide = blockForStateHide
        self.blockForStateShow = blockForStateShow
        self.blockForStateUndock = blockForStateUndock
        self.blockForStateDock = blockForStateDock
        self.blockForStateWillMove = blockForStateWillMove
        self.blockForStateDidMove = blockForStateDidMove
        
        self.initObserver(view)
    }
    
    /**
     Start observing using the CPKeyboardObserverDelegate as callback.
     
     - Parameter view: the view.
     - Parameter delegate: the delegate
    */
    func startObserving(view: UIView, delegate: CPKeyboardObserverDelegate) {
        self.delegate = delegate
        self.initObserver(view)
    }
    
    /**
     Initializes the observer.
     Inits the keyboard state and adds the NSNotificationsObserver for the 'UIKeyboardWillChangeFrameNotification' and 'UIKeyboardDidChangeFrameNotification' events.
     Init the keyboard state.
     Add the keyboard notification observer.
     
     - Parameter view: view used to hide the keyboard.
     */
    func initObserver(view: UIView) {
        self.initState(view)
        self.addObserver()
    }
    
    /**
     Initializes the keyboard state.
     Hides the keyboard using the view instance.
     
     - Parameter view: view used to hide the keyboard.
     */
    private func initState(view: UIView) {
        
        // hide the keyboard
        view.endEditing(true)
        
        // set the current keyboard state to 'hidden'
        self.currentKeyboardState = .Hidden
        // set the previous keyboard state to 'hidden'
        self.previousKeyboardState = .Hidden
        
        // initialize the helper variables
        self.hasKeyboardJustUndocked = false
        self.hasKeyboardJustDocked = false
    }
    
    /**
     Free the memory.
     */
    deinit {
        self.delegate = nil
        self.blockForStateDidMove = nil
        self.blockForStateHide = nil
        self.blockForStateShow = nil
        self.blockForStateWillMove = nil
        self.blockForStateUndock = nil
    }
    
    /**
     Remove already added observer first, then add the observer for the 'UIKeyboardWillChangeFrameNotification' and 'UIKeyboardDidChangeFrameNotification' notifications.
     */
    private func addObserver() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidChangeFrame:", name: UIKeyboardDidChangeFrameNotification, object: nil)
        
        // since the notification observer has been added observing has started
        self.isObserving = true
    }
    
    /**
     Stops observing.
     Removes the keyboard related notification observers and frees memory.
     */
    func stopObserving() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        self.delegate = nil
        self.blockForStateDidMove = nil
        self.blockForStateHide = nil
        self.blockForStateShow = nil
        self.blockForStateWillMove = nil
        
        self.isObserving = false
    }
    
    /**
     Pauses the observer.
     The observer still listens to the keyboard notification events to determine the right current keyboard state in case the observer restarts again.
     */
    func pauseObserver() {
        self.isObserving = false
    }
    
    /**
     Restarts the observer after being paused.
     */
    func restartObserver() {
        
        assert(self.delegate != nil || (self.blockForStateHide != nil && self.blockForStateHide != nil && self.blockForStateShow != nil && self.blockForStateWillMove != nil), "KeyboardStateObserver delegate or block not set")
        
        self.addObserver()
    }
    
    
    /// MARK: - Keyboard Notification events functions
    
    /**
     Notification function that gets called when the keyboard will change its frame.
    
    - Parameter notification: the notification instance received from the keyboard notification.
    */
    func keyboardWillChangeFrame(notification: NSNotification) {
        
        // since we need the information in the dictionary we cancel if there is none
        guard let userInfo = notification.userInfo else {
            print("notification doesn't contain a userInfo dictionary")
            return
        }
        
        self.calculateNextState(userInfo, caller: .KeyboardObserverCallerWillChange)
    }
    
    /**
     Notification function that gets called when the keyboard changed its frame
     
     - Parameter notification: the notification instance received from the keyboard notification.
    */
    func keyboardDidChangeFrame(notification: NSNotification) {
        
        // since we need the information in the dictionary we cancel if there is none
        guard let userInfo = notification.userInfo else {
            print("notification doesn't contain a userInfo dictionary")
            return
        }
        
        self.calculateNextState(userInfo, caller: .KeyboardObserverCallerDidChange)
    }
    
    /**
     Calculates the next state using the information held by the dictionary.
     
     - Parameter userInfo: the dictionary with the information about the keyboard frame.
     - Parameter caller: caller to determine if the keyboard will change its frame or already did change it.
     */
    func calculateNextState(userInfo: [NSObject : AnyObject], caller: KeyboardObserverCaller) {
        
        // calculate the keyboard state and position
        KeyboardStateDefinition.calculateKeyboardPosition(userInfo)
        
        // print the current state for debug purposes
        // KeyboardStateDefinition.printState()
        
        // check if the data is valid
        if KeyboardStateDefinition.isDataValid() {
            
            // transition to the next state, the current state becomes the previous state
            self.previousKeyboardState = self.currentKeyboardState
            
            // if the currentState is nil return
            guard let currentKeyboardState = self.currentKeyboardState else {
                return
            }
            
            // determine the next state by looking at the current state and the information in the dictionary.
            switch currentKeyboardState {
                
            // keyboard is hidden
            case .Hidden:
                
                if KeyboardStateDefinition.isKeyboardAtBottom! {
                    self.currentKeyboardState = .ShownDocked
                }
                else if KeyboardStateDefinition.isKeyboardDetached! {
                    self.currentKeyboardState = .ShownUndocked
                }
                
                break
                
            // keyboard is being displayed
            case .ShownDocked:
                
                if KeyboardStateDefinition.isKeyboardDetached! {
                    self.currentKeyboardState = .ShownUndocked
                }
                else if KeyboardStateDefinition.isKeyboardHidden! {
                    self.currentKeyboardState = .Hidden
                }
                
                break
                
            // keyboard is being displayed (split)
            case .ShownUndocked:
                
                if KeyboardStateDefinition.isKeyboardHidden! {
                    self.currentKeyboardState = .HiddenUndocked
                }
                else if KeyboardStateDefinition.isKeyboardAtBottom! && KeyboardStateDefinition.isKeyboardVisible! {
                    self.currentKeyboardState = .ShownDocked
                }
                
                break
                
            // keyboard gets hidden after being displayed (split)
            case .HiddenUndocked:
                
                if KeyboardStateDefinition.isKeyboardDetached! {
                    self.currentKeyboardState = .ShownUndocked
                }
                
                break
            default:
                break
            }
            
            // create a new dictionary to pass it back to the observing UIViewController via the corrresponding callback method
            guard let newFrameDictionary = self.createDictionary(userInfo) else {
                return
            }
            
            // execute the correponding code to the new state
            self.executeCodeForCurrentState(newFrameDictionary, caller: caller)
        }
    }
    
    /**
     Creates a new dictionary that will be passed to the observing UIViewController via the corresponding callback method later.
     
     - Parameter userInfo: the dictionary with the information about the keyboard frame.
     
     - Returns: a new dictionary
     */
    private func createDictionary(userInfo: [NSObject : AnyObject]) -> [NSObject : AnyObject]? {
        
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        // the new frame of the keyboard
        var newFrame = (userInfo[KeyboardFrameDictionaryKey.End] as! NSValue).CGRectValue()
        
        // the keyboard y position
        let keyboardY: CGFloat = newFrame.origin.y
        
        // the space between the keyboard y position and the bottom of the screen (aka the keyboard height)
        // In some cases the userInfo contained a wrong keyboard height value, that's why we calculate it by ourselves
        let spaceBetweenKeyboardStartAndScreenEnd: CGFloat = (screenHeight - keyboardY)
        var fixedKeyboardHeight: CGFloat = newFrame.size.height
        
        // fix keyboard data (e.g. set the height of the keyboard to '0' when hidden)
        if spaceBetweenKeyboardStartAndScreenEnd <= 0 {
            fixedKeyboardHeight = 0.0
        }
        else if spaceBetweenKeyboardStartAndScreenEnd < newFrame.size.height {
            fixedKeyboardHeight = spaceBetweenKeyboardStartAndScreenEnd
        }
        
        // use the fixed keyboard height
        if fixedKeyboardHeight != newFrame.size.height {
            newFrame.size.height = fixedKeyboardHeight
        }
        
        // the new fixed dictionary
        let newFrameDictionary: [NSObject : AnyObject] = [KeyboardFrameDictionaryKey.CPKeyboardStateObserverNewFrameKey : NSValue(CGRect: newFrame), KeyboardFrameDictionaryKey.CPKeyboardStateObserverOriginalKeyboardFrame : userInfo]
        
        return newFrameDictionary
    }
    
    /**
     Executes the code for the new keyboard state and notifies the observing UIViewController via the
     corresponding callback method.
     
     - Parameter userInfo: the dictionary with the information about the keyboard frame.
     - Parameter caller: caller to determine if the keyboard will change its frame or already did change it.
     */
    private func executeCodeForCurrentState(userInfo: [NSObject : AnyObject], caller: KeyboardObserverCaller) {
        
        // if is not observing don't do anything
        if !self.isObserving {
            return
        }
        
        // execute the corresponding code for the current and previous state
        switch self.currentKeyboardState! {
            
        case .Hidden: fallthrough
        case .HiddenUndocked: fallthrough
        case .HiddenSplit:
            // hide event
            if self.delegate != nil {
                self.delegate.keyboardWillHide(self, keyboardInfo: userInfo)
            }
            else {
                self.blockForStateHide(keyboardInfo: userInfo)
            }
            
            self.hasKeyboardJustDocked = false
            
            break
            
        case .ShownDocked:
            // keyboard returns to the bottom of the screen
            if self.previousKeyboardState == KeyboardObserverState.ShownUndocked ||
                self.previousKeyboardState == KeyboardObserverState.ShownSplit {
                    
                    if self.delegate != nil {
                        self.delegate.keyboardWillDock(self, keyboardInfo: userInfo)
                    }
                    else {
                        self.blockForStateDock(keyboardInfo: userInfo)
                    }
                    
                    self.hasKeyboardJustUndocked = false
                    self.hasKeyboardJustDocked = true
                    
                    break
            }
            else {
                if self.hasKeyboardJustDocked {
                    return
                }
                
                if self.delegate != nil {
                    self.delegate.keyboardWillShow(self, keyboardInfo: userInfo)
                }
                else {
                    self.blockForStateShow(keyboardInfo: userInfo)
                }
            }
            
            break
            
        case .ShownUndocked: fallthrough
        case .ShownSplit:
            
            // detach event
            if self.previousKeyboardState == KeyboardObserverState.ShownDocked {
                
                if self.delegate != nil {
                    self.delegate.keyboardWillUndock(self, keyboardInfo: userInfo)
                }
                else {
                    self.blockForStateUndock(keyboardInfo: userInfo)
                }
                
                self.hasKeyboardJustDocked = false
                self.hasKeyboardJustUndocked = true
            }
                // the keyboard moved while being detached
            else if self.previousKeyboardState == KeyboardObserverState.ShownUndocked {
                // the keyboard will move
                if caller == KeyboardObserverCaller.KeyboardObserverCallerWillChange {
                    if self.delegate != nil {
                        self.delegate.keyboardWillMove(self, keyboardInfo: userInfo)
                    }
                    else {
                        self.blockForStateWillMove(keyboardInfo: userInfo)
                    }
                    
                    //                    self.hasKeyboardJustUndocked = false
                }
                // the keyboard did move or undock/detach
                else {
                    // it's the undock/detach event
                    if self.hasKeyboardJustUndocked {
                        // reset the variable after the keyboard animation has finished
                        self.delay(keyboardAnimationTime, closure: { () -> () in
                            self.hasKeyboardJustUndocked = false
                        })
                        
                        if self.delegate != nil {
                            self.delegate.keyboardWillUndock(self, keyboardInfo: userInfo)
                        }
                        else {
                            self.blockForStateUndock(keyboardInfo: userInfo)
                        }
                        
                        return
                    }
                    
                    // it's the did move event
                    if self.delegate != nil {
                        self.delegate.keyboardDidMove(self, keyboardInfo: userInfo)
                    }
                    else {
                        self.blockForStateDidMove(keyboardInfo: userInfo)
                    }
                }
                
            }
            else {
                // the keyboard will move
                if caller == KeyboardObserverCaller.KeyboardObserverCallerWillChange {
                    if self.delegate != nil {
                        self.delegate.keyboardWillMove(self, keyboardInfo: userInfo)
                    }
                    else {
                        self.blockForStateWillMove(keyboardInfo: userInfo)
                    }
                }
                else {
                    // it's the undock/detach event
                    if self.hasKeyboardJustUndocked {
                        if self.delegate != nil {
                            self.delegate.keyboardWillUndock(self, keyboardInfo: userInfo)
                        }
                        else {
                            self.blockForStateUndock(keyboardInfo: userInfo)
                        }
                        
                        return
                    }
                    
                    // it's the did move event
                    if self.delegate != nil {
                        self.delegate.keyboardDidMove(self, keyboardInfo: userInfo)
                    }
                    else {
                        self.blockForStateDidMove(keyboardInfo: userInfo)
                    }
                }
            }
        }
    }
    
    /**
     
     */
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}