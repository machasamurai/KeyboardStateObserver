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

There are two ways to receive the CPKeyboardStateObserver keyboarb event callbacks.

#### Use the CPKeyboardObserverDelegate Protocol

In order to conform to the CPKeyboardObserverDelegate protocol you have to adopt it in your UIViewController.

	class ViewController: UIViewController, CPKeyboardObserverDelegate

To conform to the CPKeyboardObserverDelegate you have to implement the following methods:

	/** 'Keyboard will hide' event.
    - Parameter keyboardStateObserver: CPKeyboardStateObserver instance.
    - Parameter keyboardInfo: Dictionary that contains the keyboard frame values.
     */
    **func keyboardWillHide(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject])**
    
    /** 'Keyboard will show' event.
    - Parameter keyboardStateObserver: CPKeyboardStateObserver instance.
    - Parameter keyboardInfo: Dictionary that contains the keyboard frame values.
    */
    func keyboardWillShow(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject])
    
    /** 'Keyboard will undock' event. The keyboard detaches from the bottom of the screen.
    - Parameter keyboardStateObserver: CPKeyboardStateObserver instance.
    - Parameter keyboardInfo: Dictionary that contains the keyboard frame values.
    */
    func keyboardWillUndock(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject])
    
    /** 'Keyboard will dock event. The keyboard attaches to the bottom of the screen.
    - Parameter keyboardStateObserver: CPKeyboardStateObserver instance.
    - Parameter keyboardInfo: Dictionary that contains the keyboard frame values.
    */
    func keyboardWillDock(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject])
    
    /** 'Keyboard will move' event. The keyboard will be moved by the user while being detached from the bottom of the screen.
    - Parameter keyboardStateObserver: CPKeyboardStateObserver instance.
    - Parameter keyboardInfo: Dictionary that contains the keyboard frame values.
    */
    func keyboardWillMove(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject])
    
    /** 'Keyboard did move' event. The keyboard was moved by the user while being detached from the bottom of the screen.
    - Parameter keyboardStateObserver: CPKeyboardStateObserver instance.
    - Parameter keyboardInfo: Dictionary that contains the keyboard frame values.
     */
    func keyboardDidMove(keyboardStateObserver: CPKeyboardStateObserver, keyboardInfo: [NSObject : AnyObject])


To start observing and getting notified about keyboard state changes you start the observer using the singleton with the following code:
        
	CPKeyboardStateObserver.sharedObserver.startObserving(self.view, delegate: self)

You have to pass the singleton instance two parameters

- the view of the observing UIViewController (used to hide the keyboard if neccessary)
- the class that conforms to the CPKeyboardStateDelegate Protocol



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