//
//  DetailViewController.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 2/18/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController, WhitakerScraperDelegate, ButtonFooterViewDelegate, UIViewControllerTransitioningDelegate {
    @IBOutlet weak var abbreviationCell: UITableViewCell!
    @IBOutlet weak var fulltextCell: UITableViewCell!
    @IBOutlet weak var searchforCell: UITableViewCell!
    
    @IBOutlet var buttonFooterView: ButtonFooterView!
    
    var whitakers = WhitakerScraper()
    var fulltextFooterView: ButtonFooterView!
    
    var lastSelectedIndexPath: NSIndexPath?
    
    var detailItem: Abbreviation! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    var sections: [(header:String?, content:String)]!
    
    let ABBREVIATION_SECTION_INDEX = 0
    let FULLTEXT_SECTION_INDEX = 1
    let SEARCHFORWITH_SECTION_INDEX = 2

    func configureView() {
        if self.detailItem == nil {
            var defaultView = NSBundle.mainBundle().loadNibNamed("DefaultDetailView", owner: self, options: nil)[0] as! UIView
            self.view = defaultView
        }
        else {
            if let displayText = self.detailItem.displayText {
                self.sections = [
                    (header: nil, content: displayText.stringByReplacingOccurrencesOfString("·", withString: "", options: .allZeros))
                ]
            }
            else {
                self.sections = [
                    (header: nil, content: self.detailItem.displayImage!)
                ]
            }
            self.sections.append(header:nil, content:self.detailItem.longText)
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
            self.tableView.contentInset = UIEdgeInsetsMake(-dummyViewHeight + 10, 0, 0, 0);
            
            self.tableView.registerNib(UINib(nibName: "BasicCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "basicCell")
            self.tableView.registerNib(UINib(nibName: "InscribedCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "inscribedCell")
            
            self.whitakers.delegate = self
            
            self.definesPresentationContext = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showWords" {
            let def = segue.destinationViewController as! DefinitionViewController
            def.result = sender as! WhitakerResult
            def.transitioningDelegate = self
            def.modalPresentationStyle = .Custom
        }
    }
    
    override func shouldAutorotate() -> Bool {
        println("Calling shouldAutorotate() in DetailViewController")
        if self.presentedViewController != nil {
            return false
        }
        else {
            return true
        }
    }
    
    view
    
    override func viewDidAppear(animated: Bool) {
        let inscribedCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: ABBREVIATION_SECTION_INDEX)) as! InscribedCell
        inscribedCell.updateBackgroundFrame()
    }
    
    //MARK: - UITableViewController
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == ABBREVIATION_SECTION_INDEX {
            var cell = self.tableView.dequeueReusableCellWithIdentifier("inscribedCell") as! InscribedCell
            if self.detailItem.displayText != nil {
                cell.mainLabel!.text = self.sections[indexPath.section].content
                cell.mainLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody, scaleFactor: 2)
            }
            else if let displayImage = self.detailItem.displayImage {
                cell.centerImageView.image = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource(displayImage, ofType: ".png")!)!
                cell.centerImageView.contentMode = UIViewContentMode.ScaleAspectFit
                cell.mainLabel!.hidden = true
                cell.userInteractionEnabled = false
            }
            return cell
        }
        else {
            var cell = self.tableView.dequeueReusableCellWithIdentifier("basicCell") as! BasicCell
            cell.mainLabel!.text = self.sections[indexPath.section].content
            cell.mainLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody, scaleFactor: 1.1)
            cell.mainLabel!.textAlignment = NSTextAlignment.Center
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == FULLTEXT_SECTION_INDEX {
            NSBundle.mainBundle().loadNibNamed("ButtonFooterView", owner: self, options: nil)
            
            self.buttonFooterView.buttonDelegate = self
            self.fulltextFooterView = self.buttonFooterView
            
            return self.buttonFooterView
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == FULLTEXT_SECTION_INDEX {
            return 30
        }
        
        return 0
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
        self.fulltextFooterView.currentState = .Loading
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
        self.fulltextFooterView.currentState = .Default
        self.performSegueWithIdentifier("showWords", sender: result)
    }
    
    func whitakerScraper(scraper: WhitakerScraper, didFailWithError error: NSError) {
        self.fulltextFooterView.currentState = .Default
        
        var alert = UIAlertController(title: "Oops!", message: error.description, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - ButtonFooterViewDelegate
    
    func buttonFooterView(footerView: ButtonFooterView, buttonPressed button: UIButton) {
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