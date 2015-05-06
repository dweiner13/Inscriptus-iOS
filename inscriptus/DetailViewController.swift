//
//  DetailViewController.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 2/18/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController, WhitakerScraperDelegate, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var abbreviationCell: UITableViewCell!
    @IBOutlet weak var fulltextCell: UITableViewCell!
    @IBOutlet weak var searchforCell: UITableViewCell!
    
    @IBOutlet var detailHeaderView: DetailHeaderView!
    
    var whitakers = WhitakerScraper()
    
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
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        return self.detailHeaderView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.becomeFirstResponder() {
            self.lastSelectedIndexPath = indexPath
            var menuController = UIMenuController.sharedMenuController()
            
            if self.lastSelectedIndexPath?.section == FULLTEXT_SECTION_INDEX {
                let lookupItem = UIMenuItem(title: "Define", action: "lookupDefinitions:")
                menuController.menuItems = [lookupItem]
            }
            else {
                menuController.menuItems = nil
            }
            
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
    
    func lookupDefinitions(sender: AnyObject?) {
        if let indexPath = self.lastSelectedIndexPath {
            var alert = UIAlertController(title: "Select a word", message: nil, preferredStyle: .ActionSheet)
            let longText = self.sections[indexPath.section].content
            for word in longText.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
                let action = UIAlertAction(title: word, style: .Default) {
                    action -> Void in
                    self.whitakers.beginDefinitionRequestForWord(word, targetLanguage: .English)
                }
                alert.addAction(action)
            }
            let action = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alert.addAction(action)
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
    
    func whitakerScraper(scraper: WhitakerScraper, didLoadDefinitions definitions: [WhitakerDefinition], forWord word: String, withTargetLanguage targetLanguage: WhitakerScraper.TargetLanguage, rawResult result: String) {
        var alert = UIAlertController(title: word, message: definitions[0].meanings!, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func whitakerScraper(scraper: WhitakerScraper, didFailWithError error: NSError) {1
        var alert = UIAlertController(title: "Oops!", message: error.description, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}