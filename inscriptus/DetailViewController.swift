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
    
    var detailItem: Abbreviation! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    var sections: [(header:String, content:String)]!

    func configureView() {
        self.sections = [
            (header:"Abbreviation", content:self.detailItem.displayText!),
            (header:"Full text", content:self.detailItem.longText),
            (header:"Search for with", content:self.detailItem.searchStrings!.first!)
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
        NSLog("Hi")
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
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        NSBundle.mainBundle().loadNibNamed("DetailHeaderView", owner: self, options: nil)
        
        self.detailHeaderView.textLabel.text = self.sections[section].header
        
        return self.detailHeaderView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 37.0
    }
}