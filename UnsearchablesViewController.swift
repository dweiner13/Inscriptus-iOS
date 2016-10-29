//
//  UnsearchablesViewController.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 2/21/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class UnsearchablesViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, UIViewControllerTransitioningDelegate {
    
    // MARK: - Properties
    
    static let searchScopeIndexAbbreviation = 0
    static let searchScopeIndexFulltext = 1
    
    var abbreviations = AbbreviationCollection.sharedAbbreviationCollection
    var filteredAbbreviations = Array<Abbreviation>()
    var searchController: UISearchController?

    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.definesPresentationContext = true
        self.tableView.rowHeight = 60
        
        self.tableView.register(UINib(nibName: "AbbreviationCell", bundle: nil), forCellReuseIdentifier: "AbbreviationCell")
        
        self.searchController = UISearchController(searchResultsController: nil)
        if let searchController = self.searchController {
            let searchBar = searchController.searchBar
            searchBar.scopeButtonTitles = ["Abbreviation", "Full text"]
            searchBar.sizeToFit()
            searchBar.delegate = self
            self.tableView.tableHeaderView = searchBar
            searchController.searchResultsUpdater = self
            searchBar.searchBarStyle = .default
            searchController.dimsBackgroundDuringPresentation = false
            
            searchBar.selectedScopeButtonIndex = ApplicationState.sharedApplicationState().scopeIndex
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !ApplicationState.sharedApplicationState().specialCoachHidden {
            self.performSegue(withIdentifier: "ShowSpecialCoach", sender: self)
        }
    }
    
    // Handle scroll bar insets when search bar is active
    func keyboardDidShow(_ sender: Notification) {
        let dict: NSDictionary = sender.userInfo! as NSDictionary
        let height: CGFloat = (dict.object(forKey: UIKeyboardFrameEndUserInfoKey)! as AnyObject).cgRectValue.height
        
        var insets = self.tableView.scrollIndicatorInsets
        self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: insets.top, left: insets.left, bottom: height, right: insets.right)
        insets = self.tableView.contentInset
        self.tableView.contentInset = UIEdgeInsets(top: insets.top, left: insets.left, bottom: height, right: insets.right)
    }
    func keyboardDidHide(_ sender: Notification) {
        var insets = self.tableView.scrollIndicatorInsets
        self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: insets.top, left: insets.left, bottom: 0, right: insets.right)
        insets = self.tableView.contentInset
        self.tableView.contentInset = UIEdgeInsets(top: insets.top, left: insets.left, bottom: 0, right: insets.right)
    }

    // MARK: Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if !self.searchController!.isActive || self.searchController!.searchBar.text!.characters.count == 0 {
                return self.abbreviations.specialAbbreviations.count
            }
            else {
                return self.filteredAbbreviations.count
            }
        }
        else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AbbreviationCell", for: indexPath) as! AbbreviationCell
        
        let abbreviation: Abbreviation
        
        if self.searchController!.isActive && self.searchController!.searchBar.text!.characters.count != 0 {
            abbreviation = self.filteredAbbreviations[indexPath.row]
        }
        else {
            abbreviation = self.abbreviations.specialAbbreviations[indexPath.row]
        }
        
        cell.setAbbreviation(abbreviation, searchController: self.searchController)
        
        return cell
    }

    // MARK: Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let abbreviation = self.abbreviations.specialAbbreviations[indexPath.row]
                
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = abbreviation
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        else if segue.identifier == "ShowSpecialCoach" {
            let coach = segue.destination as! SpecialCoachController
            coach.transitioningDelegate = self
            coach.modalPresentationStyle = .custom
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text;
        
        let scopeIndex = searchController.searchBar.selectedScopeButtonIndex;
        
        self.abbreviations.asyncSearchSpecialsForString(searchString!, scopeIndex: scopeIndex, onFinish: {
            results in
            self.filteredAbbreviations = results
            self.tableView.reloadData()
        })
    }
    
    // updateSearchResultsForSearchController() should be called when scope changed but isn't
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResults(for: self.searchController!)
        
        ApplicationState.sharedApplicationState().scopeIndex = selectedScope
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if !self.searchController!.isActive {
            let insets = self.tableView.scrollIndicatorInsets
            self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: insets.top + 88, left: insets.left, bottom: insets.bottom, right: insets.right)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if self.searchController!.isActive {
            let insets = self.tableView.scrollIndicatorInsets
            self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 20, left: insets.left, bottom: insets.bottom, right: insets.right)
        }
    }
    
    //MARK: Transitioning delegate
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = smallModalAnimator(presenting: true)
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = smallModalAnimator(presenting: false)
        return animator
    }
}
