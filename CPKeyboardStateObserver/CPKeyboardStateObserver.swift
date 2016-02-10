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
    
    static let sharedObserver = CPKeyboardStateObserver()
    
    var delegate: CPKeyboardObserverDelegate!
    
    var blockForStateHide: BlockForState!
    var blockForStateShow: BlockForState!
    var blockForStateUndock: BlockForState!
    var blockForStateDock: BlockForState!
    var blockForStateWillMove: BlockForState!
    var blockForStateDidMove: BlockForState!
    
    var currentKeyboardState: KeyboardObserverState!
    var previousKeyboardState: KeyboardObserverState!
    
    var hasKeyboardJustUndocked: Bool = false
    var hasKeyboardJustDocked: Bool = false
    
    var isObserving: Bool = false
    
    let keyboardAnimationTime = 0.5
    
    
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
    
    
    enum KeyboardObserverState: Int {
        case Hidden
        case ShownDocked
        case ShownUndocked
        case HiddenUndocked
        case ShownSplit
        case HiddenSplit
    }
    
    
    enum KeyboardObserverCaller: Int {
        case KeyboardObserverCallerWillChange
        case KeyboardObserverCallerDidChange
    }
    
    
    func startObserving(view: UIView, blockForStateHide: BlockForState, blockForStateShow: BlockForState, blockForStateUndock: BlockForState, blockForStateDock: BlockForState, blockForStateWillMove: BlockForState, blockForStateDidMove: BlockForState) {
        
        self.blockForStateHide = blockForStateHide
        self.blockForStateShow = blockForStateShow
        self.blockForStateUndock = blockForStateUndock
        self.blockForStateDock = blockForStateDock
        self.blockForStateWillMove = blockForStateWillMove
        self.blockForStateDidMove = blockForStateDidMove
        
        self.initObserver(view)
    }
    
    
    func startObserving(view: UIView, delegate: CPKeyboardObserverDelegate) {
        
        self.delegate = delegate
        self.initObserver(view)
    }
    
    
    func initObserver(view: UIView) {
        
        self.initState(view)
        
//        self.delay(self.keyboardAnimationTime) { () -> () in
            self.addObserver()
//        }
    }
    
    
    private func initState(view: UIView) {
        
        view.endEditing(true)
        
        self.currentKeyboardState = .Hidden
        self.previousKeyboardState = .Hidden
        self.hasKeyboardJustUndocked = false
        self.hasKeyboardJustDocked = false
    }
    
    
    deinit {
        self.delegate = nil
        self.blockForStateDidMove = nil
        self.blockForStateHide = nil
        self.blockForStateShow = nil
        self.blockForStateWillMove = nil
    }
    
    
    private func addObserver() {
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow"), name: UIKeyboardWillShowNotification, object: nil)
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidHide"), name: UIKeyboardDidHideNotification, object: nil)
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide"), name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidChangeFrame:", name: UIKeyboardDidChangeFrameNotification, object: nil)
        
        self.isObserving = true
    }
    
    
    func stopObserving() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        self.delegate = nil
        self.blockForStateDidMove = nil
        self.blockForStateHide = nil
        self.blockForStateShow = nil
        self.blockForStateWillMove = nil
        
        self.isObserving = false
    }
    
    
    func pauseObserver() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        self.isObserving = false
    }
    
    
    func restartObserver() {
        
        assert(self.delegate != nil || (self.blockForStateHide != nil && self.blockForStateHide != nil && self.blockForStateShow != nil && self.blockForStateWillMove != nil), "KeyboardStateObserver delegate or block not set")
        
        self.addObserver()
    }
    
    
    /// MARK: - Keyboard Notification events methods
    
    
    func keyboardWillChangeFrame(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else {
            print("notification doesn't contain a userInfo dictionary")
            return
        }
        
        self.calculateNextState(userInfo, caller: .KeyboardObserverCallerWillChange)
    }
    
    
    func keyboardDidChangeFrame(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else {
            print("notification doesn't contain a userInfo dictionary")
            return
        }
        
        self.calculateNextState(userInfo, caller: .KeyboardObserverCallerDidChange)
    }
    
    
    func calculateNextState(userInfo: [NSObject : AnyObject], caller: KeyboardObserverCaller) {
        
        KeyboardStateDefinition.calculateKeyboardPosition(userInfo)
        KeyboardStateDefinition.printState()
        
        if KeyboardStateDefinition.isDataValid() {
            
            self.previousKeyboardState = self.currentKeyboardState
            
            guard let currentKeyboardState = self.currentKeyboardState else {
                print("currentKeyboardState is nil")
                return
            }
            
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
                    self.currentKeyboardState = .ShownUndocked
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
            
            guard let newFrameDictionary = self.createDictionary(userInfo) else {
                return
            }
            
            self.executeCodeForCurrentState(newFrameDictionary, caller: caller)
        }
    }
    
    
    private func createDictionary(userInfo: [NSObject : AnyObject]) -> [NSObject : AnyObject]? {
        
        let screenHeight = UIScreen.mainScreen().bounds.size.height

        var newFrame = (userInfo[KeyboardFrameDictionaryKey.End] as! NSValue).CGRectValue()
        
        let keyboardY: CGFloat = newFrame.origin.y
        
        let spaceBetweenKeyboardStartAndScreenEnd: CGFloat = (screenHeight - keyboardY)
        var fixedKeyboardHeight: CGFloat = newFrame.size.height
        
        // fix keyboard data (e.g. set the height of the keyboard to '0' when hidden)
        if spaceBetweenKeyboardStartAndScreenEnd <= 0 {
            fixedKeyboardHeight = 0.0
        }
        else if spaceBetweenKeyboardStartAndScreenEnd < newFrame.size.height {
            fixedKeyboardHeight = spaceBetweenKeyboardStartAndScreenEnd
        }
        
        if fixedKeyboardHeight != newFrame.size.height {
            newFrame.size.height = fixedKeyboardHeight
        }
        
        let newFrameDictionary: [NSObject : AnyObject] = [KeyboardFrameDictionaryKey.CPKeyboardStateObserverNewFrameKey : NSValue(CGRect: newFrame), KeyboardFrameDictionaryKey.CPKeyboardStateObserverOriginalKeyboardFrame : userInfo]
        
        return newFrameDictionary
    }
    
    
    private func executeCodeForCurrentState(userInfo: [NSObject : AnyObject], caller: KeyboardObserverCaller) {
        
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
            else {
                if caller == KeyboardObserverCaller.KeyboardObserverCallerWillChange {
                    if self.delegate != nil {
                        self.delegate.keyboardWillMove(self, keyboardInfo: userInfo)
                    }
                    else {
                        self.blockForStateWillMove(keyboardInfo: userInfo)
                    }
                
                    self.hasKeyboardJustUndocked = false
                }
                else {
                    if self.hasKeyboardJustUndocked {
                        return
                    }
                
                    self.hasKeyboardJustUndocked = false
                    return
                }
                
                if self.delegate != nil {
                    self.delegate.keyboardDidMove(self, keyboardInfo: userInfo)
                }
                else {
                    self.blockForStateDidMove(keyboardInfo: userInfo)
                }
            }
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}