//
//  MasterViewController.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 2/18/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

let useDictionaryForSearch = true

class MasterViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    let searchScopeIndexAbbreviation = 0
    let searchScopeIndexFulltext = 1

    var detailViewController: DetailViewController? = nil
    var allAbbreviations = Array<Abbreviation>()
    var abbreviationsGrouped = [String: Array<Abbreviation>]()
    
    var specialAbbreviations = Array<Abbreviation>()
    
    var searchController: UISearchController?
    
    var filteredAbbreviations = Array<Abbreviation>()

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
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
        }
        
        // Load abbreviations arrays
        let combinedPath: String = NSBundle.mainBundle().pathForResource("abbs-combined", ofType: "json")!
        let combinedData = NSData(contentsOfFile: combinedPath)!
        var err: NSError?
        let combinedAbbreviations: NSArray = NSJSONSerialization.JSONObjectWithData(combinedData, options: .allZeros, error: &err) as! NSArray
        
        var abbreviations = Array<Abbreviation>()
        for abbreviation in combinedAbbreviations {
            let newAbbreviation = Abbreviation(JSONDict: abbreviation as! NSDictionary)
            abbreviations.append(newAbbreviation)
            
            if self.abbreviationsGrouped[newAbbreviation.searchableText] != nil {
                self.abbreviationsGrouped[newAbbreviation.searchableText]?.append(newAbbreviation)
            }
            else {
                self.abbreviationsGrouped[newAbbreviation.searchableText] = [newAbbreviation]
            }
        }
        
        self.allAbbreviations = abbreviations
        
        // Special character abbreviations
        
        let specialcharsPath: String = NSBundle.mainBundle().pathForResource("abbs-specialchars", ofType: "json")!
        let specialcharData = NSData(contentsOfFile: specialcharsPath)!
        let specialcharAbbreviations: NSArray = NSJSONSerialization.JSONObjectWithData(specialcharData, options: .allZeros, error: &err) as! NSArray
        for abbreviation in specialcharAbbreviations {
            let newAbbreviation = Abbreviation(JSONDict: abbreviation as! NSDictionary)
            self.specialAbbreviations.append(newAbbreviation)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                    abbreviation = self.allAbbreviations[indexPath.row]
                }
                
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = abbreviation
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        } // Handle transition to special character view
        else if segue.destinationViewController is UnsearchablesViewController {
            (segue.destinationViewController as! UnsearchablesViewController).specialAbbreviations = self.specialAbbreviations
            print((segue.destinationViewController as! UnsearchablesViewController).specialAbbreviations)
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section==0 {
            return 1
        }
        else {
            if self.searchController!.active && count(self.searchController!.searchBar.text) != 0 {
                return self.filteredAbbreviations.count
            }
            else {
                return self.allAbbreviations.count
            }
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section==0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SpecialCharsCell", forIndexPath: indexPath) as! AbbreviationCell
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("AbbreviationCell", forIndexPath: indexPath) as! AbbreviationCell
            
            var abbreviation: Abbreviation
            if self.searchController!.active && count(self.searchController!.searchBar.text) != 0 {
                abbreviation = self.filteredAbbreviations[indexPath.row]
            }
            else {
                abbreviation = self.allAbbreviations[indexPath.row]
            }
            
            if let displayText = abbreviation.displayText {
                cell.primaryLabel.text = abbreviation.displayText;
            }
            else {
                cell.primaryLabel.text = "[symbol: \(abbreviation.searchableText)]"
            }
            cell.secondaryLabel.text = abbreviation.longText;
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            self.performSegueWithIdentifier("showDetail", sender: self)
        }
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        var searchString = searchController.searchBar.text;
        
        var scopeIndex = searchController.searchBar.selectedScopeButtonIndex;
        
        self.filteredAbbreviations = self.searchForString(searchString, scopeIndex: scopeIndex)
        self.tableView.reloadData()
    }
    
    func searchForString(searchString: String, scopeIndex: Int) -> [Abbreviation] {
        var resultAbbreviations = [Abbreviation]()
        
        if scopeIndex == self.searchScopeIndexAbbreviation {
            if let matchingAbbreviations = self.abbreviationsGrouped[searchString] {
                resultAbbreviations = matchingAbbreviations
            }
            else if let matchingAbbreviations = self.abbreviationsGrouped[searchString.uppercaseString] {
                resultAbbreviations = matchingAbbreviations
            }
            var i = 0
            for key: String in self.abbreviationsGrouped.keys {
                if count(key)>count(searchString) && key[0..<count(searchString)].lowercaseString == searchString.lowercaseString {
                    if let matchingAbbreviations: [Abbreviation] = self.abbreviationsGrouped[key] {
                        resultAbbreviations.extend(matchingAbbreviations)
                    }
                }
            }
        }
        else if scopeIndex == self.searchScopeIndexFulltext {
            for abbreviation: Abbreviation in allAbbreviations {
                if abbreviation.longText.rangeOfString(searchString, options: .CaseInsensitiveSearch) != nil {
                    resultAbbreviations.append(abbreviation)
                }
            }
        }
        
        println("\(searchString) \(scopeIndex)")
        
        return resultAbbreviations
    }
    
    // updateSearchResultsForSearchController() should be called when scope changed but isnt
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
            self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 64, left: insets.left, bottom: insets.bottom, right: insets.right)
        }
    }
}

