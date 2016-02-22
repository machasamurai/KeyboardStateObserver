# CPKeyboardStateObserver
Thank you for using CPKeyboardStateObserver, an observer for keyboard state changes on iPad and iPhone.

## Introduction
CPKeyboardStateObserver is an observer which, once registered, listens to keyboard state events and reports back the corresponding event and additionally provides you with the new keyboard frame information.
You can use the CPKeyboardObserverDelagate as callback method or alternatively use closures/blocks.

## How to get started
Just add the CPKeyboardStateObserver.swift to your project and start observing.
For more details take a look at the 'usage' section.

## Requirements
CPKeyboardStateObserver needs iOS 8 and higher.

It depends on the following frameworks:

* Foundation.framework
* UIKit.framework

## Usage

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