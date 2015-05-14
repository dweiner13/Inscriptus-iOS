//
//  MasterViewController.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 2/18/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    let abbreviations = AbbreviationCollection.sharedAbbreviationCollection
    
    static let searchScopeIndexAbbreviation = 0
    static let searchScopeIndexFulltext = 1
    
    // Only valid if self.isShowingFavorites is false
    let SPECIAL_ABBREVIATIONS_SECTION_INDEX = 0
    let ALL_ABBREVIATIONS_SECTION_INDEX = 1
    
    var isShowingFavorites: Bool = false {
        didSet {
            let range = NSMakeRange(0, 2)
            if self.isShowingFavorites {
                self.tableView.reloadData()
//                self.tableView.beginUpdates()
//                self.tableView.deleteSections(NSIndexSet(indexesInRange: range), withRowAnimation: .Fade)
//                self.tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
//                self.tableView.endUpdates()
            }
            else {
                self.tableView.reloadData()
//                self.tableView.beginUpdates()
//                self.tableView.deleteSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
//                self.tableView.insertSections(NSIndexSet(indexesInRange: range), withRowAnimation: .Fade)
//                self.tableView.endUpdates()
            }
        }
    }

    var detailViewController: DetailViewController? = nil
    var searchController: UISearchController?
    var filteredAbbreviations = Array<Abbreviation>()
    
    func didPressBookmarksButton(sender: UIBarButtonItem) {
        if self.isShowingFavorites {
            sender.setBackgroundImage(nil, forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
            sender.tintColor = UIApplication.sharedApplication().delegate?.window??.tintColor
            self.isShowingFavorites = !self.isShowingFavorites
        }
        else {
            sender.setBackgroundImage(UIImage(named: "bookmarks-bg.png"), forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
            sender.tintColor = UIColor.whiteColor()
            self.isShowingFavorites = !self.isShowingFavorites
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
        
        var buttonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: "didPressBookmarksButton:")
        self.navigationItem.rightBarButtonItem = buttonItem
    }
    
    override func viewWillAppear(animated: Bool) {
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
        
        self.definesPresentationContext = true
        self.tableView.rowHeight = 60
        
        self.tableView.registerNib(UINib(nibName: "AbbreviationCell", bundle: nil), forCellReuseIdentifier: "AbbreviationCell")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)
        
        // Set up search controller
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
            
            searchBar.selectedScopeButtonIndex = ApplicationState.sharedApplicationState().scopeIndex
        }
    }
    
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

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                var abbreviation: Abbreviation
                
                if self.searchController!.active && count(self.searchController!.searchBar.text) != 0 {
                    abbreviation = self.filteredAbbreviations[indexPath.row]
                }
                else {
                    abbreviation = self.abbreviations.allAbbreviations[indexPath.row]
                }
                
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = abbreviation
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.isShowingFavorites {
            return 1
        }
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isShowingFavorites {
            return self.abbreviations.favorites.count
        }
        if section == SPECIAL_ABBREVIATIONS_SECTION_INDEX {
            if !self.searchController!.active || count(self.searchController!.searchBar.text) == 0 {
                return 1
            }
            else {
                return 0
            }
        }
        if section == ALL_ABBREVIATIONS_SECTION_INDEX {
            if self.searchController!.active && count(self.searchController!.searchBar.text) != 0 {
                return self.filteredAbbreviations.count
            }
            else {
                return self.abbreviations.allAbbreviations.count
            }
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.isShowingFavorites {
            let cell = tableView.dequeueReusableCellWithIdentifier("AbbreviationCell", forIndexPath: indexPath) as! AbbreviationCell
            
            var abbreviation: Abbreviation
            if self.searchController!.active && count(self.searchController!.searchBar.text) != 0 {
                abbreviation = self.filteredAbbreviations[indexPath.row]
            }
            else {
                abbreviation = self.abbreviations.favorites[indexPath.row] as! Abbreviation
            }
            
            cell.setAbbreviation(abbreviation, searchController: self.searchController!)
            
            return cell
        }
        if indexPath.section == SPECIAL_ABBREVIATIONS_SECTION_INDEX {
            let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
            cell.textLabel?.text = "Special character abbreviations"
            cell.accessoryType = .DisclosureIndicator
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("AbbreviationCell", forIndexPath: indexPath) as! AbbreviationCell
            
            var abbreviation: Abbreviation
            if self.searchController!.active && count(self.searchController!.searchBar.text) != 0 {
                abbreviation = self.filteredAbbreviations[indexPath.row]
            }
            else {
                abbreviation = self.abbreviations.allAbbreviations[indexPath.row]
            }
            
            cell.setAbbreviation(abbreviation, searchController: self.searchController!)
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.isShowingFavorites {
            self.performSegueWithIdentifier("showDetail", sender: self)
        }
        else if indexPath.section == SPECIAL_ABBREVIATIONS_SECTION_INDEX {
            self.performSegueWithIdentifier("showUnsearchables", sender: self)
        }
        else if indexPath.section == ALL_ABBREVIATIONS_SECTION_INDEX {
            self.performSegueWithIdentifier("showDetail", sender: self)
        }
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        var searchString = searchController.searchBar.text;
        
        var scopeIndex = searchController.searchBar.selectedScopeButtonIndex;
        
        if self.isShowingFavorites {
            self.abbreviations.asyncSearchFavoritesForString(searchString, scopeIndex: scopeIndex, onFinish: {
                results in
                self.filteredAbbreviations = results
                self.tableView.reloadData()
            })
        }
        else {
            self.abbreviations.asyncSearchForString(searchString, scopeIndex: scopeIndex, onFinish: {
                results in
                self.filteredAbbreviations = results
                self.tableView.reloadData()
            })
        }
    }
    
    // updateSearchResultsForSearchController() should be called when scope changed but isn't
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResultsForSearchController(self.searchController!)
        ApplicationState.sharedApplicationState().scopeIndex = selectedScope
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

