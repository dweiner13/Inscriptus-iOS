//
//  UnsearchablesViewController.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 2/21/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class UnsearchablesViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    static let searchScopeIndexAbbreviation = 0
    static let searchScopeIndexFulltext = 1
    
    var abbreviations = AbbreviationCollection.sharedAbbreviationCollection
    var filteredAbbreviations = Array<Abbreviation>()
    var searchController: UISearchController?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.definesPresentationContext = true
        self.tableView.rowHeight = 60
        
        self.tableView.registerNib(UINib(nibName: "AbbreviationCell", bundle: nil), forCellReuseIdentifier: "AbbreviationCell")
        
        self.searchController = UISearchController(searchResultsController: nil)
        if let searchController = self.searchController {
            var searchBar = searchController.searchBar
            searchBar.scopeButtonTitles = ["Abbreviation", "Full text"]
            searchBar.sizeToFit()
            searchBar.delegate = self
            self.tableView.tableHeaderView = searchBar
            searchController.searchResultsUpdater = self
            searchBar.searchBarStyle = .Default
            searchController.dimsBackgroundDuringPresentation = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
    }
    
    // Handle scroll bar insets when search bar is active
    func keyboardDidShow(sender: NSNotification) {
        let dict: NSDictionary = sender.userInfo! as NSDictionary
        let height: CGFloat = dict.objectForKey(UIKeyboardFrameEndUserInfoKey)!.CGRectValue().height
        
        var insets = self.tableView.scrollIndicatorInsets
        self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: insets.top, left: insets.left, bottom: height, right: insets.right)
        insets = self.tableView.contentInset
        self.tableView.contentInset = UIEdgeInsets(top: insets.top, left: insets.left, bottom: height, right: insets.right)
    }
    func keyboardDidHide(sender: NSNotification) {
        var insets = self.tableView.scrollIndicatorInsets
        self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: insets.top, left: insets.left, bottom: 0, right: insets.right)
        insets = self.tableView.contentInset
        self.tableView.contentInset = UIEdgeInsets(top: insets.top, left: insets.left, bottom: 0, right: insets.right)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if !self.searchController!.active || count(self.searchController!.searchBar.text) == 0 {
                return count(self.abbreviations.specialAbbreviations)
            }
            else {
                return count(self.filteredAbbreviations)
            }
        }
        else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AbbreviationCell", forIndexPath: indexPath) as! AbbreviationCell
        
        let abbreviation: Abbreviation
        
        if self.searchController!.active && count(self.searchController!.searchBar.text) != 0 {
            abbreviation = self.filteredAbbreviations[indexPath.row]
        }
        else {
            abbreviation = self.abbreviations.specialAbbreviations[indexPath.row]
        }
        
        cell.setAbbreviation(abbreviation, searchController: self.searchController)
        
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                var abbreviation = self.abbreviations.specialAbbreviations[indexPath.row]
                
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = abbreviation
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showDetail", sender: self)
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        var searchString = searchController.searchBar.text;
        
        var scopeIndex = searchController.searchBar.selectedScopeButtonIndex;
        
        self.abbreviations.asyncSearchSpecialsForString(searchString, scopeIndex: scopeIndex, onFinish: {
            results in
            self.filteredAbbreviations = results
            self.tableView.reloadData()
        })
    }
    
    // updateSearchResultsForSearchController() should be called when scope changed but isn't
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResultsForSearchController(self.searchController!)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if !self.searchController!.active {
            var insets = self.tableView.scrollIndicatorInsets
            self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: insets.top + 88, left: insets.left, bottom: insets.bottom, right: insets.right)
        }
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        if self.searchController!.active {
            var insets = self.tableView.scrollIndicatorInsets
            self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 20, left: insets.left, bottom: insets.bottom, right: insets.right)
        }
    }
}
