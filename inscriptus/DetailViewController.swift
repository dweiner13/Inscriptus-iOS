//
//  DetailViewController.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 2/18/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {
    @IBOutlet weak var abbreviationCell: UITableViewCell!
    @IBOutlet weak var fulltextCell: UITableViewCell!
    @IBOutlet weak var searchforCell: UITableViewCell!
    
    @IBOutlet var detailHeaderView: DetailHeaderView!
    
    var lastSelectedTableViewCell: UITableViewCell?
    
    var detailItem: Abbreviation! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    var sections: [(header:String, content:String)]!

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
            let dummyViewHeight: CGFloat = 40.0
            var dummyView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyViewHeight))
            self.tableView.tableHeaderView = dummyView;
            self.tableView.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0);
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
        var cell = UITableViewCell(style: .Default, reuseIdentifier: "defaultCell")
        cell.textLabel!.text = self.sections[indexPath.section].content
        cell.textLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody, scaleFactor: 1.1)
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
            self.lastSelectedTableViewCell = self.tableView.cellForRowAtIndexPath(indexPath)
            var menuController = UIMenuController.sharedMenuController()
            menuController.setTargetRect(self.tableView.rectForRowAtIndexPath(indexPath), inView: self.tableView)
            menuController.setMenuVisible(true, animated: true)
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)

        }
    }
    
    override func copy(sender: AnyObject?) {
        if let cell = self.lastSelectedTableViewCell {
            var pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.string = cell.textLabel!.text
            println(cell.textLabel!.text)
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
}