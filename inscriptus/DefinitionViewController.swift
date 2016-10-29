//
//  DefinitionViewController.swift
//  Latin Companion iOS
//
//  Created by Daniel A. Weiner on 2/7/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

protocol DefinitionViewControllerDelegate {
    func didDismissDefinitionViewController(_ viewController: DefinitionViewController)
}

class DefinitionViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    fileprivate let cellIdentifier = "definitionCell"
    
    @IBOutlet weak var errorTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    weak var popoverController: UIPopoverController?
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    var result: WhitakerResult!
    
    var delegate: DefinitionViewControllerDelegate?
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 130.0; // set to whatever your "average" cell height is
        
        if self.result != nil {
            updateResult(self.result)
        }
        
        let topInset = CGFloat(-12)
        self.tableView.contentInset           = UIEdgeInsets(top: topInset, left: 0, bottom: 44, right:0);
        self.tableView.scrollIndicatorInsets  = UIEdgeInsets(top: topInset, left: 0, bottom: 44,  right: 0)
        self.errorTextView.textContainerInset = UIEdgeInsets(top: topInset, left: 8, bottom: 44, right: 8)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateResult(_ result: WhitakerResult) {
        self.tableView.isHidden = false
        self.errorTextView.isHidden = true
        self.result = result
        
        self.title = self.result.word
        self.navigationItem.title = self.result.word
            
        self.tableView.reloadData()
    }
    
    func showError(_ error: NSError) {
        self.errorTextView.isHidden = false;
        self.tableView.isHidden = true;
        
        let asciiError = "  _    _ _                _     _ \n | |  | | |              | |   | |\n | |  | | |__ ______ ___ | |__ | |\n | |  | | '_ \\______/ _ \\| '_ \\| |\n | |__| | | | |    | (_) | | | |_|\n  \\____/|_| |_|     \\___/|_| |_(_)";
        
        let additionalHelpText = "You can still look up words in your history list."
        
        self.errorTextView.text = "\(asciiError)\n\n\(error.localizedDescription)\n\n\(additionalHelpText)"
    }
    
    func keyboardDidShow(_ notification: Notification) {
        // Adjust table view content insets to compensate for keyboard
        if let dict: NSDictionary = notification.userInfo as NSDictionary? {
            let s: NSValue = dict.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue;
            let rect: CGRect = s.cgRectValue
            
            self.tableView.contentInset          = UIEdgeInsets(top: 0, left: 0, bottom: rect.height + 12, right: 0)
            self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: rect.height, right: 0)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if let dict: NSDictionary = notification.userInfo as NSDictionary? {
            let s: NSValue = dict.value(forKey: UIKeyboardAnimationDurationUserInfoKey) as! NSValue;
            let duration: NSNumber = s as! NSNumber
            
            
            UIView.animate(withDuration: duration as TimeInterval,
                delay: 0.0,
                options: UIViewAnimationOptions.curveEaseIn,
                animations: {
                    self.tableView.contentInset          = UIEdgeInsets(top: 0, left: 0, bottom: 12, right:0);
                    self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
                },
                completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // if it's being displayed in a popover, set the popover size
        // now that we know the actual row heights
        if let PC = self.popoverController {
            PC.contentSize = CGSize(width: 400.0, height: self.tableView.rect(forSection: 0).size.height)
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        if let delegate = self.delegate {
            delegate.didDismissDefinitionViewController(self)
        }
    }
    
    func tappedOutsideModal(_ sender: AnyObject?) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        if let delegate = self.delegate {
            delegate.didDismissDefinitionViewController(self)
        }
    }
}

extension DefinitionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.result.definitions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DefinitionCell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DefinitionCell
        
        let definition = self.result.definitions[indexPath.row]
        
        cell.definitionTextView!.text = definition.textWithoutMeanings
        
        if let meanings = definition.meanings {
            cell.meaningsTextView!.text = meanings
            cell.meaningsTextView!.isHidden = false
        }
        else {
            cell.meaningsTextView!.isHidden = true
        }
        
        if definition.isAlternateSpelling {
            cell.connectedToPreviousCell = true
        }
        
        cell.definitionHeightConstraint.constant = cell.definitionTextView.sizeThatFits(CGSize(width: self.tableView.frame.width - 8, height: CGFloat.greatestFiniteMagnitude)).height
        
        cell.definitionTextView!.backgroundColor = definition.lightColor
        cell.meaningsTextView!.backgroundColor = definition.darkColor
        
        return cell
    }
    
}
