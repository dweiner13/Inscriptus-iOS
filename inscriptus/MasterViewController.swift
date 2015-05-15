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
    
    var showFavoritesButton: UIBarButtonItem!
    
    static let searchScopeIndexAbbreviation = 0
    static let searchScopeIndexFulltext = 1
    
    // Saves the scroll offset while in favorites list
    var allListOffset: CGFloat?
    var favoritesListOffset: CGFloat?
    
    // Only valid if self.isShowingFavorites is false
    let SPECIAL_ABBREVIATIONS_SECTION_INDEX = 0
    let ALL_ABBREVIATIONS_SECTION_INDEX = 1
    
    var defaultView: UIView?
    
    var isShowingFavorites: Bool = false {
        didSet {
            self.tableView.reloadData()
            if self.isShowingFavorites {
                self.showFavoritesButton.setBackgroundImage(UIImage(named: "bookmarks-bg.png"), forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
                self.showFavoritesButton.tintColor = UIColor.whiteColor()
                self.navigationItem.title = "Favorites"
                self.navigationItem.backBarButtonItem!.title = "Favorites"
                self.searchController.searchBar.placeholder = "Search favorites"
                self.allListOffset = self.tableView.contentOffset.y
                if let offset = self.favoritesListOffset {
                    self.tableView.contentOffset.y = offset
                }
                if abbreviations.noFavorites {
                    self.showDefaultView(true)
                    self.showEditButton(false)
                }
                else {
                    self.showEditButton(true)
                }
            }
            else {
                self.showFavoritesButton.setBackgroundImage(nil, forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
                self.showFavoritesButton.tintColor = INSCRIPTUS_TINT_COLOR
                self.navigationItem.title = "All Abbreviations"
                self.navigationItem.backBarButtonItem!.title = "All"
                self.searchController.searchBar.placeholder = "Search all"
                self.favoritesListOffset = self.tableView.contentOffset.y
                if let offset = self.allListOffset {
                    self.tableView.contentOffset.y = offset
                }
                self.showEditButton(false)
                self.showDefaultView(false)
            }
        }
    }

    var detailViewController: DetailViewController? = nil
    var searchController: UISearchController!
    var filteredAbbreviations = Array<Abbreviation>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
        self.showFavoritesButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: "didPressBookmarksButton:")
        self.navigationItem.rightBarButtonItem = self.showFavoritesButton
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
            searchBar.placeholder = "Search all"
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
    
    // MARK: - UI Stuff
    
    
    
    func showDefaultView(showView: Bool) {
        if showView {
            var defaultView = NSBundle.mainBundle().loadNibNamed("DefaultFavoritesView", owner: self, options: nil)[0] as! UIView
            defaultView.frame = self.view.bounds
            self.tableView.backgroundView = defaultView
            self.tableView.separatorStyle = .None
            self.navigationItem.leftBarButtonItem = nil
            self.tableView.tableHeaderView = nil
        }
        else {
            self.defaultView?.removeFromSuperview()
            self.tableView.separatorStyle = .SingleLine
            self.tableView.backgroundView = nil
            self.tableView.tableHeaderView = self.searchController.searchBar
        }
    }
    
    func showEditButton(showButton: Bool) {
        if showButton {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "didPressEditButton:")
        }
        else {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    func didPressBookmarksButton(sender: UIBarButtonItem) {
        self.isShowingFavorites = !self.isShowingFavorites
    }
    
    func didPressEditButton(sender: UIBarButtonItem) {
        if self.isShowingFavorites {
            if self.tableView.editing {
                self.tableView.setEditing(false, animated: true)
                self.navigationItem.rightBarButtonItem = self.showFavoritesButton
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "didPressEditButton:")
            }
            else {
                self.tableView.setEditing(true, animated: true)
                self.navigationItem.rightBarButtonItem = nil
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "didPressEditButton:")
            }
        }
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                var abbreviation: Abbreviation
                
                if self.isShowingFavorites {
                    abbreviation = self.abbreviations.favorites[indexPath.row] as! Abbreviation
                }
                else if self.searchController!.active && count(self.searchController!.searchBar.text) != 0 {
                    abbreviation = self.filteredAbbreviations[indexPath.row]
                }
                else {
                    if self.searchController!.active && count(self.searchController!.searchBar.text) != 0 {
                        abbreviation = self.filteredAbbreviations[indexPath.row]
                    }
                    else {
                        let letter = self.abbreviations.abbreviationsFirstLetters[indexPath.section - 1]
                        abbreviation = self.abbreviations.abbreviationsGroupedByFirstLetter[letter]![indexPath.row]
                    }
                }
                
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = abbreviation
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View Delegate

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.isShowingFavorites {
            return 1
        }
        else {
            return count(self.abbreviations.abbreviationsGroupedByFirstLetter) + 1
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isShowingFavorites {
            if self.searchController!.active && count(self.searchController!.searchBar.text) != 0 {
                return self.filteredAbbreviations.count
            }
            else {
                return self.abbreviations.favorites.count
            }
        }
        if section == SPECIAL_ABBREVIATIONS_SECTION_INDEX {
            if !self.searchController!.active || count(self.searchController!.searchBar.text) == 0 {
                return 1
            }
            else {
                return 0
            }
        }
        else {
            if self.searchController!.active && count(self.searchController!.searchBar.text) != 0 {
                return self.filteredAbbreviations.count
            }
            else {
                return count(self.abbreviations.abbreviationsGroupedByFirstLetter[self.abbreviations.abbreviationsFirstLetters[section - 1]]!)
            }
        }
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
                let letter = self.abbreviations.abbreviationsFirstLetters[indexPath.section - 1]
                abbreviation = self.abbreviations.abbreviationsGroupedByFirstLetter[letter]![indexPath.row]
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
        else {
            self.performSegueWithIdentifier("showDetail", sender: self)
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if self.isShowingFavorites {
            return true
        }
        return false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if self.isShowingFavorites && editingStyle == UITableViewCellEditingStyle.Delete {
            self.abbreviations.removeFavorite(self.abbreviations.favorites[indexPath.row] as! Abbreviation)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            if self.abbreviations.noFavorites {
                showDefaultView(true)
            }
        }
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        self.abbreviations.moveFavoriteFromIndex(sourceIndexPath.row, toIndex: destinationIndexPath.row)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SPECIAL_ABBREVIATIONS_SECTION_INDEX {
            return nil
        }
        return self.abbreviations.abbreviationsFirstLetters[section - 1]
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        if self.isShowingFavorites {
            return []
        }
        var sectionTitles = [""]
        sectionTitles.extend(self.abbreviations.abbreviationsFirstLetters)
        return sectionTitles
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

