//
//  DetailViewController.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 2/18/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController, WhitakerScraperDelegate, DetailHeaderViewDelegate, UIViewControllerTransitioningDelegate {
    @IBOutlet weak var abbreviationCell: UITableViewCell!
    @IBOutlet weak var fulltextCell: UITableViewCell!
    @IBOutlet weak var searchforCell: UITableViewCell!
    
    @IBOutlet var detailHeaderView: DetailHeaderView!
    
    var whitakers = WhitakerScraper()
    var fullTextHeader: DetailHeaderView!
    
    var lastSelectedIndexPath: NSIndexPath?
    
    var detailItem: Abbreviation! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    var sections: [(header:String, content:String)]!
    
    let ABBREVIATION_SECTION_INDEX = 0
    let FULLTEXT_SECTION_INDEX = 1
    let SEARCHFORWITH_SECTION_INDEX = 2

    func configureView() {
        if self.detailItem == nil {
            var defaultView = NSBundle.mainBundle().loadNibNamed("DefaultDetailView", owner: self, options: nil)[0] as! UIView
            self.view = defaultView
        }
        else {
            self.sections = [
                (header:"Abbreviation", content:self.detailItem.displayText!),
                (header:"Full text", content:self.detailItem.longText),
                (header:"Search for with", content:self.detailItem.searchStrings!.first!)
            ]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
        if self.detailItem != nil {
            // Allows flexible cell height
            self.tableView.rowHeight = UITableViewAutomaticDimension
            self.tableView.estimatedRowHeight = 44.0
            
            let dummyViewHeight: CGFloat = 40.0
            var dummyView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyViewHeight))
            self.tableView.tableHeaderView = dummyView;
            self.tableView.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0);
            
            self.tableView.registerNib(UINib(nibName: "BasicCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "basicCell")
            
            self.whitakers.delegate = self
            
            self.definesPresentationContext = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "showDefinitions" {
//            let def = segue.destinationViewController as! DefinitionViewController
//            
//            def.result = sender as! WhitakerResult
//        }
        if segue.identifier == "showWords" {
            let def = segue.destinationViewController as! DefinitionViewController
            def.result = sender as! WhitakerResult
            def.transitioningDelegate = self
            def.modalPresentationStyle = .Custom
        }
    }
    
    override func shouldAutorotate() -> Bool {
        println("Calling shouldAutorotate() in DetialViewController")
        if self.presentedViewController != nil {
            return false
        }
        else {
            return true
        }
    }
    
    //MARK: - UITableViewController
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("basicCell") as! BasicCell
        cell.mainLabel!.text = self.sections[indexPath.section].content
        cell.mainLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody, scaleFactor: 1.1)
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        NSBundle.mainBundle().loadNibNamed("DetailHeaderView", owner: self, options: nil)
        
        self.detailHeaderView.textLabel.text = self.sections[section].header
        
        if section == FULLTEXT_SECTION_INDEX {
            self.detailHeaderView.lookupButton.hidden = false
            self.detailHeaderView.buttonDelegate = self
            self.fullTextHeader = detailHeaderView
        }
        
        return self.detailHeaderView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.becomeFirstResponder() {
            self.lastSelectedIndexPath = indexPath
            var menuController = UIMenuController.sharedMenuController()
            
            menuController.setTargetRect(self.tableView.rectForRowAtIndexPath(indexPath), inView: self.tableView)
            menuController.setMenuVisible(true, animated: true)
            
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    //MARK: - UIMenuController
    
    override func copy(sender: AnyObject?) {
        if let indexPath = self.lastSelectedIndexPath {
            var pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.string = self.sections[indexPath.section].content
        }
    }
    
    func lookupDefinitions(button: UIButton) {
        self.whitakers.beginDefinitionRequestForWord(self.sections[FULLTEXT_SECTION_INDEX].content, targetLanguage: .English)
        self.fullTextHeader.currentState = .Loading
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == "copy:" {
            return true
        }
        else {
            return super.canPerformAction(action, withSender: sender)
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    //MARK: - WhitakerScraperDelegate
    
    func whitakerScraper(scraper: WhitakerScraper, didLoadResult result: WhitakerResult) {
        self.fullTextHeader.currentState = .Default
        self.performSegueWithIdentifier("showWords", sender: result)
    }
    
    func whitakerScraper(scraper: WhitakerScraper, didFailWithError error: NSError) {
        self.fullTextHeader.currentState = .Default
        
        var alert = UIAlertController(title: "Oops!", message: error.description, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - DetailHeaderViewDelegate
    
    func detailHeaderView(headerView: DetailHeaderView, lookupButtonPressed button: UIButton, label: UILabel) {
        self.lookupDefinitions(button)
    }
    
    //MARK: - UIViewControllerTransitioningDelegate
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let headerRect = self.tableView.rectForHeaderInSection(FULLTEXT_SECTION_INDEX)
        let cellRect = self.tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: FULLTEXT_SECTION_INDEX))
        let bothRect = CGRectUnion(headerRect, cellRect)
        var animator = foldOutAnimator(presenting: true, foldOutBelowRect: cellRect)
        return animator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let headerRect = self.tableView.rectForHeaderInSection(FULLTEXT_SECTION_INDEX)
        let cellRect = self.tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: FULLTEXT_SECTION_INDEX))
        let bothRect = CGRectUnion(headerRect, cellRect)
        var animator = foldOutAnimator(presenting: false, foldOutBelowRect: cellRect)
        return animator
    }
}