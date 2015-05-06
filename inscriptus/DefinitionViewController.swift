//
//  DefinitionViewController.swift
//  Latin Companion iOS
//
//  Created by Daniel A. Weiner on 2/7/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class DefinitionViewController: UIViewController {
    
    private let cellIdentifier = "definitionCell"
    
    @IBOutlet weak var errorTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    
    var definitions = [WhitakerDefinition]()
    weak var popoverController: UIPopoverController?
    var rawText: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 130.0; // set to whatever your "average" cell height is
        
        self.tableView.contentInset          = UIEdgeInsets(top: 0, left: 0, bottom: 44 + 12, right:0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 44,  right: 0)
        
        self.errorTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 4, right: 8)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateDefinitions(definitions: [WhitakerDefinition], rawText: String) {
        self.tableView.hidden = false
        self.errorTextView.hidden = true
        self.rawText = rawText
        
        self.actionButton.enabled = true;
        
        self.definitions = definitions
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
        if let raw = self.rawText {
            var activityController: UIActivityViewController = UIActivityViewController(activityItems: [raw], applicationActivities: nil)
            activityController.popoverPresentationController?.barButtonItem = sender;
            
            self.showViewController(activityController, sender: self)
        }
    }
}

extension DefinitionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.definitions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: DefinitionCell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! DefinitionCell
        
        var definition = self.definitions[indexPath.row]
        
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
