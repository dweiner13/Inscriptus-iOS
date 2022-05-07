//
//  MasterViewController.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 2/18/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, UIViewControllerPreviewingDelegate, UISearchControllerDelegate {
    
    // MARK: - Properties
    
    let abbreviations = AbbreviationCollection.sharedAbbreviationCollection
    
    // The button to show favorites
    var showFavoritesButton: UIBarButtonItem!
    
    static let searchScopeIndexAbbreviation = 0
    static let searchScopeIndexFulltext = 1
    
    // Saves the scroll offset when transitioning to/from favorites list
    var savedScrollOffset: CGPoint?
    
    // The view to display when there are no favorites
    var defaultView: UIView?
    
    // The button to show the about screen
    var aboutButton: UIBarButtonItem!
    
    var focusSearchBar = false {
        didSet {
            searchController.isActive = true
            searchController.searchBar.becomeFirstResponder()
        }
    }
    
    // True to show user favorites, false to show all abbreviations
    var isShowingFavorites: Bool = false {
        didSet {
            // Save scroll position
            let scrollOffset = self.tableView.contentOffset
            
            self.tableView.reloadData()
            
            // Restore scroll position
            if let savedOffset = self.savedScrollOffset {
                self.tableView.contentOffset = savedOffset
            }

            if #available(iOS 15.0, *) {
                showFavoritesButton.isSelected = isShowingFavorites
            }
            showFavoritesButton.image = isShowingFavorites ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
            
            self.savedScrollOffset = scrollOffset
            
            if self.isShowingFavorites {
                self.navigationItem.title = "Favorites"
                self.navigationItem.backBarButtonItem!.title = "Favorites"
                self.searchController.searchBar.placeholder = "Search favorites"
                
                if abbreviations.noFavorites {
                    self.showDefaultView(true)
                    self.showEditButton(false)
                }
                else {
                    self.showEditButton(true)
                }
            }
            else {
                self.navigationItem.title = "All Abbreviations"
                self.navigationItem.backBarButtonItem!.title = "All"
                self.searchController.searchBar.placeholder = "Search all"
                
                self.showEditButton(false)
                self.showDefaultView(false)
            }
        }
    }

    var detailViewController: DetailViewController? = nil
    var searchController: UISearchController!
    
    // Abbreviations filtered based on the current user search string
    var filteredAbbreviations = Array<Abbreviation>()
    
    // MARK: - Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
        self.showFavoritesButton = UIBarButtonItem(image: UIImage(systemName: "star"),
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(didPressBookmarksButton(_:)))
        self.navigationItem.rightBarButtonItem = self.showFavoritesButton
        self.aboutButton = UIBarButtonItem(title: "About", style: UIBarButtonItem.Style.plain, target: self, action: #selector(MasterViewController.tappedAboutButton(_:)))
        self.navigationItem.leftBarButtonItem = self.aboutButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
        self.tableView.reloadData()
        
        if self.isShowingFavorites && abbreviations.noFavorites {
            self.showDefaultView(true)
            self.showEditButton(false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("view did appear")
        if (focusSearchBar) {
            print("focusSearchBar so setting searchController to active")
            self.searchController.isActive = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            let navController = controllers[controllers.count - 1] as! UINavigationController
            self.detailViewController = navController.topViewController as? DetailViewController
        }
        
        self.definesPresentationContext = true
        self.tableView.rowHeight = 60
        
        self.tableView.register(UINib(nibName: "AbbreviationCell", bundle: nil), forCellReuseIdentifier: "AbbreviationCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(MasterViewController.keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MasterViewController.keyboardDidHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        // Set up search controller
        self.searchController = UISearchController(searchResultsController: nil)
        if let searchController = self.searchController {
            let searchBar = searchController.searchBar
            searchBar.placeholder = "Search all"
            searchBar.scopeButtonTitles = ["Abbreviation", "Full text"]
            searchBar.sizeToFit()
            searchBar.delegate = self
            searchController.searchResultsUpdater = self
            searchController.delegate = self
            searchBar.searchBarStyle = .default

            navigationItem.searchController = searchController
            
            searchBar.selectedScopeButtonIndex = ApplicationState.sharedApplicationState().scopeIndex
        }
        
        registerForPreviewing(with: self, sourceView: view)
    }
    
    @objc func keyboardDidShow(_ sender: Notification) {
        let dict: NSDictionary = sender.userInfo! as NSDictionary
        let height: CGFloat = (dict.object(forKey: UIResponder.keyboardFrameEndUserInfoKey)! as AnyObject).cgRectValue.height
        
        var insets = self.tableView.scrollIndicatorInsets
        self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: insets.top, left: insets.left, bottom: height, right: insets.right)
        insets = self.tableView.contentInset
        self.tableView.contentInset = UIEdgeInsets(top: insets.top, left: insets.left, bottom: height, right: insets.right)
    }
    
    @objc func keyboardDidHide(_ sender: Notification) {
        var insets = self.tableView.scrollIndicatorInsets
        self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: insets.top, left: insets.left, bottom: 0, right: insets.right)
        insets = self.tableView.contentInset
        self.tableView.contentInset = UIEdgeInsets(top: insets.top, left: insets.left, bottom: 0, right: insets.right)
    }
    
    func getAbbreviation(indexPath: IndexPath) -> Abbreviation {
        var abbreviation: Abbreviation
        
        if self.isShowingFavorites {
            abbreviation = self.abbreviations.favorites[indexPath.row] as! Abbreviation
        }
        else if self.inSearchView {
            abbreviation = self.filteredAbbreviations[indexPath.row]
        }
        else {
            if self.inSearchView {
                abbreviation = self.filteredAbbreviations[indexPath.row]
            }
            else {
                let letter = self.abbreviations.abbreviationsFirstLetters[indexPath.section - 1]
                abbreviation = self.abbreviations.abbreviationsGroupedByFirstLetter[letter]![indexPath.row]
            }
        }
        
        return abbreviation;
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        print("did present searchController")
        if (focusSearchBar) {
            searchController.searchBar.becomeFirstResponder()
            focusSearchBar = false
        }
    }
    
    // MARK: UI Stuff

    @objc
    func tappedAboutButton(_ sender: AnyObject) {
        let aboutViewController = ModalWebViewController(htmlFileName: "about", title: "About Inscriptus", modalPresentationStyle: UIModalPresentationStyle.formSheet);
        
        aboutViewController?.allowScrolling = false;
        self.present(aboutViewController!, animated: true, completion: nil);
    }
    
    func showDefaultView(_ showView: Bool) {
        if showView {
            let defaultView = Bundle.main.loadNibNamed("DefaultFavoritesView", owner: self, options: nil)?[0] as! UIView
            defaultView.frame = self.view.bounds
            self.tableView.backgroundView = defaultView
            self.tableView.separatorStyle = .none
            self.navigationItem.leftBarButtonItem = nil
        }
        else {
            self.defaultView?.removeFromSuperview()
            self.tableView.separatorStyle = .singleLine
            self.tableView.backgroundView = nil
        }
    }
    
    func showEditButton(_ showButton: Bool) {
        if showButton {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(MasterViewController.didPressEditButton(_:)))
        }
        else {
            self.navigationItem.leftBarButtonItem = self.aboutButton
        }
    }

    @objc
    func didPressBookmarksButton(_ sender: UIBarButtonItem) {
        self.isShowingFavorites = !self.isShowingFavorites
    }
    
    @objc func didPressEditButton(_ sender: UIBarButtonItem) {
        if self.isShowingFavorites {
            if self.tableView.isEditing {
                self.tableView.setEditing(false, animated: true)
                self.navigationItem.rightBarButtonItem = self.showFavoritesButton
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(MasterViewController.didPressEditButton(_:)))
            }
            else {
                self.tableView.setEditing(true, animated: true)
                self.navigationItem.rightBarButtonItem = nil
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(MasterViewController.didPressEditButton(_:)))
            }
        }
    }
    
    var inSearchView: Bool {
        get {
            return self.searchController!.isActive && self.searchController!.searchBar.text!.count != 0
        }
    }

    // MARK: Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            print("showDetail segue")
            let abbreviation = sender as! Abbreviation
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            controller.detailItem = abbreviation
            controller.navigationItem.leftItemsSupplementBackButton = true
            
            AbbreviationCollection.sharedAbbreviationCollection.pushViewed(abbreviation: abbreviation)
        }
    }

    // MARK: Table View Delegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.isShowingFavorites {
            return 1
        }
        if self.inSearchView {
            return 1
        }
        else {
            return self.abbreviations.abbreviationsGroupedByFirstLetter.count + 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isShowingFavorites {
            if section == 0 {
                if self.inSearchView {
                    return self.filteredAbbreviations.count
                }
                else {
                    return self.abbreviations.favorites.count
                }
            }
        }
        else {
            if section == 0 {
                if self.inSearchView {
                    return self.filteredAbbreviations.count
                }
                else {
                    return 1
                }
            }
            else {
                return (self.abbreviations.abbreviationsGroupedByFirstLetter[self.abbreviations.abbreviationsFirstLetters[section - 1]]!).count
            }
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isShowingFavorites && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AbbreviationCell", for: indexPath) as! AbbreviationCell
            
            var abbreviation: Abbreviation
            if self.inSearchView {
                abbreviation = self.filteredAbbreviations[indexPath.row]
            }
            else {
                abbreviation = self.abbreviations.favorites[indexPath.row] as! Abbreviation
            }
            
            cell.setAbbreviation(abbreviation, searchController: self.searchController!)
            
            return cell
        }
        else {
            if indexPath.section == 0 && !self.inSearchView {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
                cell.textLabel?.text = "Special character abbreviations"
                cell.accessoryType = .disclosureIndicator
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AbbreviationCell", for: indexPath) as! AbbreviationCell
                
                var abbreviation: Abbreviation
                if self.inSearchView {
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
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isShowingFavorites {
            self.performSegue(withIdentifier: "showDetail", sender: self.getAbbreviation(indexPath: indexPath))
        }
        else if indexPath.section == 0 && !self.inSearchView {
            self.performSegue(withIdentifier: "showUnsearchables", sender: self)
        }
        else {
            self.performSegue(withIdentifier: "showDetail", sender: self.getAbbreviation(indexPath: indexPath))
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.isShowingFavorites {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if self.isShowingFavorites && editingStyle == UITableViewCell.EditingStyle.delete {
            self.abbreviations.removeFavorite(self.abbreviations.favorites[indexPath.row] as! Abbreviation)
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            if self.abbreviations.noFavorites {
                showDefaultView(true)
                self.navigationItem.rightBarButtonItem = self.showFavoritesButton
                self.tableView.setEditing(false, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.isShowingFavorites || self.inSearchView {
            return nil
        }
        else {
            if section == 0 {
                return nil
            }
            return self.abbreviations.abbreviationsFirstLetters[section - 1]
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if self.isShowingFavorites || self.inSearchView {
            return []
        }
        var sectionTitles = [""]
        sectionTitles.append(contentsOf: self.abbreviations.abbreviationsFirstLetters)
        return sectionTitles
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text;
        
        let scopeIndex = searchController.searchBar.selectedScopeButtonIndex;
        
        if self.isShowingFavorites {
            self.abbreviations.asyncSearchFavoritesForString(searchString!, scopeIndex: scopeIndex, onFinish: {
                results in
                self.filteredAbbreviations = results
                self.tableView.reloadData()
            })
        }
        else {
            self.abbreviations.asyncSearchForString(searchString!, scopeIndex: scopeIndex, onFinish: {
                results in
                self.filteredAbbreviations = results
                self.tableView.reloadData()
            })
        }
    }
    
    // updateSearchResultsForSearchController() should be called when scope
    // changed but isn't
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
    
    // MARK: - UIViewControllerPreviewingDelegate
    
    // Peek
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.tableView.indexPathForRow(at: location),
              let cell = tableView.cellForRow(at: indexPath) else { return nil }
        
        guard let detailViewController = storyboard?.instantiateViewController(withIdentifier: "detailViewController") as? DetailViewController else { return nil }
        
        detailViewController.detailItem = self.getAbbreviation(indexPath: indexPath);
        
        previewingContext.sourceRect = cell.frame;
        
        return detailViewController;
    }
    
    // Pop
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        // Reuse the "peek" view controller for presentation
        show(viewControllerToCommit, sender: self);
    }
}

