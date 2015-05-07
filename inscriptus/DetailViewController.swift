//
//  DetailViewController.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 2/18/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController, WhitakerScraperDelegate, DetailHeaderViewDelegate {
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
        if segue.identifier == "showDefinitions" {
            let def = segue.destinationViewController as! DefinitionViewController
            
            def.result = sender as! WhitakerResult
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
            self.detailHeaderView.button.hidden = false
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
        var alert = UIAlertController(title: "Select a word", message: nil, preferredStyle: .ActionSheet)
        let longText = self.sections[FULLTEXT_SECTION_INDEX].content
        
        let words = longText.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if count(words) == 1 {
            self.whitakers.beginDefinitionRequestForWord(words[0], targetLanguage: .English)
            self.fullTextHeader.activityIndicator.startAnimating()
            fullTextHeader.activityIndicator.hidden = false
            fullTextHeader.button.hidden = true
        }
        else {
            for word in words {
                let action = UIAlertAction(title: word, style: .Default) {
                    action -> Void in
                    self.whitakers.beginDefinitionRequestForWord(word, targetLanguage: .English)
                    self.fullTextHeader.activityIndicator.startAnimating()
                    self.fullTextHeader.activityIndicator.hidden = false
                    self.fullTextHeader.button.hidden = true
                }
                alert.addAction(action)
            }
            let action = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alert.addAction(action)
            alert.popoverPresentationController?.sourceView = self.fullTextHeader
            alert.popoverPresentationController?.sourceRect = button.frame
            self.presentViewController(alert, animated: true, completion: nil)
        }
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
        self.fullTextHeader.activityIndicator.stopAnimating()
        self.fullTextHeader.activityIndicator.hidden = true
        self.fullTextHeader.button.hidden = false
        self.performSegueWithIdentifier("showDefinitions", sender: result)
    }
    
    func whitakerScraper(scraper: WhitakerScraper, didFailWithError error: NSError) {
        self.fullTextHeader.activityIndicator.stopAnimating()
        self.fullTextHeader.activityIndicator.hidden = true
        self.fullTextHeader.button.hidden = false
        
        var alert = UIAlertController(title: "Oops!", message: error.description, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - DetailHeaderViewDelegate
    
    func detailHeaderView(headerView: DetailHeaderView, buttonPressed button: UIButton, label: UILabel) {
        println("Button press in delegate")
        self.lookupDefinitions(button)
    }
}