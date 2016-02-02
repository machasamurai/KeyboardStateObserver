//
//  CPKeyboardStateObserver.swift
//  CPKeyboardStateObserver
//
//  Created by ベックマンラモン on 2016/02/02.
//  Copyright © 2016年 Corepilots. All rights reserved.
//

import Foundation
import UIKit

typealias BlockForState = (keyboardDictionary: [String : String]) -> Void

protocol CPKeyboardObserverDelegate: class {
    
    /// 'Keyboard will hide' event.
    /// @param  CPKeyboardStateObserver instance.
    /// @param  Dictionary that contains the keyboard frame values.
    func keyboardWillHide(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [String : String])
    
    /// 'Keyboard will show' event.
    /// @param  CPKeyboardStateObserver instance.
    /// @param  Dictionary that contains the keyboard frame values.
    func keyboardWillShow(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [String : String])
    
    /// 'Keyboard will undock' event. The keyboard detaches from the bottom of the screen.
    /// @param  CPKeyboardStateObserver instance.
    /// @param  Dictionary that contains the keyboard frame values.
    func keyboardWillUndock(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [String : String])
    
    /// 'Keyboard will dock event. The keyboard attaches to the bottom of the screen.
    /// @param  CPKeyboardStateObserver instance.
    /// @param  Dictionary that contains the keyboard frame values.
    func keyboardWillDock(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [String : String])
    
    /// 'Keyboard will move' event. The keyboard will be moved by the user while being detached from the bottom of the screen.
    /// @param  CPKeyboardStateObserver instance.
    /// @param  Dictionary that contains the keyboard frame values.
    func keyboardWillMove(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [String : String])
    
    /// 'Keyboard did move' event. The keyboard was moved by the user while being detached from the bottom of the screen.
    /// @param  CPKeyboardStateObserver instance.
    /// @param  Dictionary that contains the keyboard frame values.
    func keyboardDidMove(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [String : String])
}

class CPKeyboardStateObserver {
    
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
    
    
    enum KeyboardObserverState: Int {
        case Hidden
        case ShownDocked
        case ShownUndocked
        case HiddenUndocked
        case ShownSplit
        case HiddenSplit
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
        
        self.delay(self.keyboardAnimationTime) { () -> () in
            self.addObserver()
        }
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillChangeFrame"), name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidChangeFrame"), name: UIKeyboardDidChangeFrameNotification, object: nil)
        
        self.isObserving = false
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
    
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}