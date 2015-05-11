//
//  DefinitionViewController.swift
//  Latin Companion iOS
//
//  Created by Daniel A. Weiner on 2/7/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class DefinitionViewController: UIViewController, UIGestureRecognizerDelegate {
    
    private let cellIdentifier = "definitionCell"
    
    @IBOutlet weak var errorTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    weak var popoverController: UIPopoverController?
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    var result: WhitakerResult!
    
    override func viewWillAppear(animated: Bool) {
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func orientationChanged(notification: NSNotification) {
        self.adjustViewsForOrientation()
    }
    
    override func shouldAutorotate() -> Bool {
        println("calling shouldAutorotate() in DefinitionViewController")
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        println("Calling supportedInterfaceOrientations()")
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    func adjustViewsForOrientation() {
        var topInset = CGFloat()
        topInset = -12
        self.tableView.contentInset           = UIEdgeInsets(top: topInset, left: 0, bottom: 44, right:0);
        self.tableView.scrollIndicatorInsets  = UIEdgeInsets(top: topInset, left: 0, bottom: 44,  right: 0)
        self.errorTextView.textContainerInset = UIEdgeInsets(top: topInset, left: 8, bottom: 44, right: 8)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 130.0; // set to whatever your "average" cell height is
        
        var topInset: CGFloat = 64
        
        self.adjustViewsForOrientation()
        if self.result != nil {
            updateResult(self.result)
        }
        
        var recognizer = UITapGestureRecognizer(target: self, action: "didRecognizeTap:")
        recognizer.numberOfTapsRequired = 1
        recognizer.cancelsTouchesInView = false
        self.view.window?.addGestureRecognizer(recognizer)
        recognizer.delegate = self
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateResult(result: WhitakerResult) {
        self.tableView.hidden = false
        self.errorTextView.hidden = true
        self.result = result
        
        self.actionButton.enabled = true;
        
        self.title = self.result.word
        self.navigationItem.title = self.result.word
            
        self.tableView.reloadData()
    }
    
    func showError(error: NSError) {
        self.errorTextView.hidden = false;
        self.tableView.hidden = true;
        
        var asciiError = "  _    _ _                _     _ \n | |  | | |              | |   | |\n | |  | | |__ ______ ___ | |__ | |\n | |  | | '_ \\______/ _ \\| '_ \\| |\n | |__| | | | |    | (_) | | | |_|\n  \\____/|_| |_|     \\___/|_| |_(_)";
        
        var additionalHelpText = "You can still look up words in your history list."
        
        self.errorTextView.text = "\(asciiError)\n\n\(error.localizedDescription)\n\n\(additionalHelpText)"
    }
    
    func keyboardDidShow(notification: NSNotification) {
        // Adjust table view content insets to compensate for keyboard
        if let dict: NSDictionary = notification.userInfo as NSDictionary? {
            let s: NSValue = dict.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue;
            let rect: CGRect = s.CGRectValue()
            
            self.tableView.contentInset          = UIEdgeInsets(top: 0, left: 0, bottom: rect.height + 12, right: 0)
            self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: rect.height, right: 0)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let dict: NSDictionary = notification.userInfo as NSDictionary? {
            let s: NSValue = dict.valueForKey(UIKeyboardAnimationDurationUserInfoKey) as! NSValue;
            let duration: NSNumber = s as! NSNumber
            
            
            UIView.animateWithDuration(duration as NSTimeInterval,
                delay: 0.0,
                options: UIViewAnimationOptions.CurveEaseIn,
                animations: {
                    self.tableView.contentInset          = UIEdgeInsets(top: 0, left: 0, bottom: 12, right:0);
                    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero
                },
                completion: nil)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        // if it's being displayed in a popover, set the popover size
        // now that we know the actual row heights
        if let PC = self.popoverController {
            PC.popoverContentSize = CGSize(width: 400.0, height: self.tableView.rectForSection(0).size.height)
        }
    }
    
    @IBAction func actionButtonPressed(sender: UIBarButtonItem) {
        var activityController: UIActivityViewController = UIActivityViewController(activityItems: [result.rawResult], applicationActivities: nil)
        activityController.popoverPresentationController?.barButtonItem = sender;
        
        self.showViewController(activityController, sender: self)
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didRecognizeTap(sender: UITapGestureRecognizer) {
        
        println("Did recognize tap")
        
        if sender.state == UIGestureRecognizerState.Ended {
            let rootView = self.view.window?.rootViewController!.view
            let tapLocation = sender.locationInView(rootView)
            if !self.view.pointInside(self.view.convertPoint(tapLocation, fromView: rootView), withEvent: nil) {
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                self.view.window?.removeGestureRecognizer(sender)
            }
        }
    }
    
    //MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension DefinitionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.result.definitions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: DefinitionCell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! DefinitionCell
        
        var definition = self.result.definitions[indexPath.row]
        
        cell.definitionTextView!.text = definition.textWithoutMeanings
        
        if let meanings = definition.meanings {
            cell.meaningsTextView!.text = meanings
            cell.meaningsTextView!.hidden = false
        }
        else {
            cell.meaningsTextView!.hidden = true
        }
        
        if definition.isAlternateSpelling {
            cell.connectedToPreviousCell = true
        }
        
        cell.definitionHeightConstraint.constant = cell.definitionTextView.sizeThatFits(CGSize(width: self.tableView.frame.width - 8, height: CGFloat.max)).height
        
        cell.definitionTextView!.backgroundColor = definition.lightColor
        cell.meaningsTextView!.backgroundColor = definition.darkColor
        
        return cell
    }
    
}
