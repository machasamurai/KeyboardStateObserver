//
//  ViewController.swift
//  CPKeyboardStateObserver
//
//  Created by ベックマンラモン on 2016/02/02.
//  Copyright © 2016年 Corepilots. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var functionButton: UIButton!
    
    var blockForStateHide: BlockForState!
    var blockForStateShow: BlockForState!
    var blockForStateUndockEvent: BlockForState!
    var blockForStateDockEvent: BlockForState!
    var blockForStateWillMove: BlockForState!
    var blockForStateDidMove: BlockForState!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ブロックを用意する
        self.initData()
        
        // ビューを用意する
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
        
        self.blockForStateHide = { (keyboardDictionary: [NSObject : AnyObject]) -> Void in
            self.stateLabel.text = "blockDidHide"
            self.moveLabel(keyboardDictionary, shouldFollowKeyboard: true)
        }
        
        self.blockForStateShow = { (keyboardDictionary: [NSObject : AnyObject]) -> Void in
            self.stateLabel.text = "blockDidShow"
            self.moveLabel(keyboardDictionary, shouldFollowKeyboard: true)
        }
        
        self.blockForStateUndockEvent = { (keyboardDictionary: [NSObject : AnyObject]) -> Void in
            self.stateLabel.text = "blockDiUndock"
            self.moveLabel(keyboardDictionary, shouldFollowKeyboard: true)
        }
        
        self.blockForStateDockEvent = { (keyboardDictionary: [NSObject : AnyObject]) -> Void in
            self.stateLabel.text = "blockDidDock"
            self.moveLabel(keyboardDictionary, shouldFollowKeyboard: true)
        }
        
        self.blockForStateWillMove = { (keyboardDictionary: [NSObject : AnyObject]) -> Void in
            self.stateLabel.text = "blockWillMove"
            self.moveLabel(keyboardDictionary, shouldFollowKeyboard: true)
        }
        
        self.blockForStateDidMove = { (keyboardDictionary: [NSObject : AnyObject]) -> Void in
//            self.stateLabel.text = "blockDidMove"
            self.moveLabel(keyboardDictionary, shouldFollowKeyboard: true)
        }
    }
    
    
    private func initViews() {
        
    }

    
    private func moveLabel(userInfo: [NSObject : AnyObject], shouldFollowKeyboard: Bool) {
        
    }
}