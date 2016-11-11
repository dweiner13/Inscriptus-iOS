//
//  AbbreviationCollection.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 3/28/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

private let _SingletonSharedInstance = AbbreviationCollection()

class AbbreviationCollection: NSObject {
    
    // MARK: - Properties
    
    // Abbreviations in a dictionary by their search text
    var abbreviationsGrouped = [String: Array<Abbreviation>]()
    var abbreviationsGroupedByFirstLetter = [String: Array<Abbreviation>]()
    var abbreviationsFirstLetters: [String]
    var specialAbbreviations = [Abbreviation]()
    var allAbbreviations = [Abbreviation]()
    var abbreviationsUnsorted = [Abbreviation]()
    
    // Predicate closure used to sort a collection of abbreviations
    let abbreviationSortClosure: (Abbreviation, Abbreviation) -> Bool = {
            (a1: Abbreviation, a2: Abbreviation) in
            let a1Text = a1.displayText != nil ? a1.displayText! : a1.longText
            let a2Text = a2.displayText != nil ? a2.displayText! : a2.longText
            return a1Text.compare(a2Text) == .orderedAscending
    }
    
    // Predicate closure to sort a collection of abbreviations ideally based on
    // a user search
    func abbreviationSortClosureForSearchString(_ searchString: String) -> (Abbreviation, Abbreviation) -> Bool {
        return {
            (a1: Abbreviation, a2: Abbreviation) in
            let a1Text = a1.displayText != nil ? a1.displayText! : a1.longText
            let a2Text = a2.displayText != nil ? a2.displayText! : a2.longText
            let a1SearchPos = a1Text.range(of: searchString, options: .caseInsensitive)?.lowerBound
            let a2SearchPos = a2Text.range(of: searchString, options: .caseInsensitive)?.lowerBound
            if a1SearchPos == a1Text.startIndex && a2SearchPos != a2Text.startIndex {
                return true
            }
            if a2SearchPos == a2Text.startIndex && a1SearchPos != a1Text.startIndex {
                return false
            }
            return a1Text.compare(a2Text) == .orderedAscending
        }
    }
    
    class var sharedAbbreviationCollection: AbbreviationCollection {
        return _SingletonSharedInstance
    }
    
    // MARK: - Methods
    
    override init() {
        // Load abbreviations arrays
        let combinedPath: String = Bundle.main.path(forResource: "abbs-combined", ofType: "json")!
        let combinedData = try! Data(contentsOf: URL(fileURLWithPath: combinedPath))
        let combinedAbbreviations: NSArray = (try! JSONSerialization.jsonObject(with: combinedData, options: [])) as! NSArray
        
        var abbreviations = [Abbreviation]()
        for abbreviation in combinedAbbreviations {
            abbreviations.append(Abbreviation(JSONDict: abbreviation as! NSDictionary))
        }
        
        self.abbreviationsUnsorted = abbreviations
        self.allAbbreviations = abbreviations.sorted(by: self.abbreviationSortClosure)
        
        // Special character abbreviations
        
        let specialcharsPath: String = Bundle.main.path(forResource: "abbs-specialchars", ofType: "json")!
        let specialcharData = try! Data(contentsOf: URL(fileURLWithPath: specialcharsPath))
        let specialcharAbbreviations: NSArray = (try! JSONSerialization.jsonObject(with: specialcharData, options: [])) as! NSArray
        for abbreviation in specialcharAbbreviations {
            self.specialAbbreviations.append(Abbreviation(JSONDict: abbreviation as! NSDictionary))
        }
        
        // Create dictionary of abbreviations grouped by search string
        for abb in self.allAbbreviations {
            if let searchStrs = abb.searchStrings {
                for searchString in searchStrs {
                    if self.abbreviationsGrouped[searchString] != nil {
                        self.abbreviationsGrouped[searchString]?.append(abb)
                    }
                    else {
                        self.abbreviationsGrouped[searchString] = [abb]
                    }
                }
            }
        }
        
        // Create dictionary of abbreviations grouped by first letter of search
        // string (for table view index)
        for abb in self.allAbbreviations {
            if let searchStrs = abb.searchStrings {
                for searchString in searchStrs {
                    // Section title should be "#" if abb begins with a number or symbol
                    let char = CharacterSet.letters.contains(UnicodeScalar(searchString[0..<1].utf16[String.UTF16View.Index(_offset: 0)])!) ? searchString[0..<1] : "#"
                    if self.abbreviationsGroupedByFirstLetter[char] != nil {
                        self.abbreviationsGroupedByFirstLetter[char]!.append(abb)
                    }
                    else {
                        self.abbreviationsGroupedByFirstLetter[char] = [abb]
                    }
                }
            }
        }
        
        // Create array of first letters in abbreviations (for table view index)
        self.abbreviationsFirstLetters = self.abbreviationsGroupedByFirstLetter.keys.sorted(by: {
            (a: String, b: String) in
            a.compare(b, options: .caseInsensitive) == .orderedAscending
        })
        
        super.init()
        
        // Restore favorites from user defaults (user defaults is list of IDs)
        let defaults = UserDefaults.standard
        if let storedFavorites: AnyObject = defaults.object(forKey: favoritesKey) as AnyObject? {
            for favorite: Any in storedFavorites as! NSMutableArray {
                self.favorites.insert(abbreviationWithID(favorite as! NSInteger)!, at: 0)
            }
        }
        
        // Restore recently viewed from user defaults (user defaults is list of IDs)
        if let storedRecentlyViewed: AnyObject = defaults.object(forKey: recentlyViewedKey) as AnyObject? {
            for recentlyViewed: Any in storedRecentlyViewed as! NSMutableArray {
                self.recentlyViewed.insert(abbreviationWithID(recentlyViewed as! NSInteger)!, at: 0)
            }
        }
    }
    
    // Get the abbreviation for the given ID
    func abbreviationWithID(_ id: Int) -> Abbreviation? {
        var abb = self.abbreviationsUnsorted[id]
        var i = id
        while(abb.id != id) {
            i = i - 1
            abb = self.abbreviationsUnsorted[i]
        }
        return abb
    }
    
    // MARK: Searching
    
    // Search for a string in all abbreviations
    func searchForString(_ searchString: String, scopeIndex: Int) -> [Abbreviation] {
        var resultAbbreviations = Set<Abbreviation>()
        
        if scopeIndex == MasterViewController.searchScopeIndexAbbreviation {
            // Try to do an exact match
            if let matchingAbbreviations = self.abbreviationsGrouped[searchString.uppercased()] {
                resultAbbreviations = Set(matchingAbbreviations)
            }
            
            // Do a partial match too
            for key: String in self.abbreviationsGrouped.keys {
                if key.range(of: searchString.lowercased(), options: .caseInsensitive) != nil || key.range(of: searchString.lowercased().replacingOccurrences(of: " ", with: ""), options: .caseInsensitive) != nil {
                    if let matchingAbbreviations: [Abbreviation] = self.abbreviationsGrouped[key] {
                        resultAbbreviations.formUnion(matchingAbbreviations)
                    }
                }
            }
        }
        else if scopeIndex == MasterViewController.searchScopeIndexFulltext {
            for abbreviation: Abbreviation in allAbbreviations {
                if abbreviation.longText.range(of: searchString, options: .caseInsensitive) != nil {
                    resultAbbreviations.insert(abbreviation)
                }
            }
        }
        
        return Array(resultAbbreviations).sorted(by: self.abbreviationSortClosureForSearchString(searchString))
    }
    
    // Search for a string in special abbreviations
    func searchSpecialsForString(_ searchString: String, scopeIndex: Int) -> [Abbreviation] {
        var resultAbbreviations = Set<Abbreviation>()
        
        if scopeIndex == MasterViewController.searchScopeIndexAbbreviation {
            // Do a partial match too
            for abb: Abbreviation in self.specialAbbreviations {
                if let abbSearchableStrings = abb.searchStrings {
                    for str: String in abbSearchableStrings {
                        if str.range(of: searchString.lowercased(), options: .caseInsensitive) != nil || str.range(of: searchString.lowercased().replacingOccurrences(of: " ", with: ""), options: .caseInsensitive) != nil {
                            resultAbbreviations.insert(abb)
                        }
                    }
                }
            }
        }
        else if scopeIndex == MasterViewController.searchScopeIndexFulltext {
            for abbreviation: Abbreviation in self.specialAbbreviations {
                if abbreviation.longText.range(of: searchString, options: .caseInsensitive) != nil {
                    resultAbbreviations.insert(abbreviation)
                }
            }
        }
        
        
        return Array(resultAbbreviations).sorted(by: self.abbreviationSortClosureForSearchString(searchString))
    }
    
    
    // Does not sort the results like the other search functions
    func searchFavoritesForString(_ searchString: String, scopeIndex: Int) -> [Abbreviation] {
        var resultAbbreviations = [Abbreviation]()
        
        if scopeIndex == MasterViewController.searchScopeIndexAbbreviation {
            // Do a partial match too
            for favorite: Any in self.favorites {
                let abb = favorite as! Abbreviation
                if let abbSearchableStrings = abb.searchStrings {
                    for str: String in abbSearchableStrings {
                        if str.range(of: searchString.lowercased(), options: .caseInsensitive) != nil || str.range(of: searchString.lowercased().replacingOccurrences(of: " ", with: ""), options: .caseInsensitive) != nil {
                            resultAbbreviations.append(abb)
                        }
                    }
                }
            }
        }
        else if scopeIndex == MasterViewController.searchScopeIndexFulltext {
            for favorite: Any in self.favorites {
                let abbreviation = favorite as! Abbreviation
                if abbreviation.longText.range(of: searchString, options: .caseInsensitive) != nil {
                    resultAbbreviations.append(abbreviation)
                }
            }
        }
        
        return resultAbbreviations
    }
    
    // Does an asynchronous search off the main thread, so the UI doesn't lock
    // up while the user is typing
    func asyncSearchForString(_ searchString: String, scopeIndex: Int, onFinish: @escaping ([Abbreviation]) -> Void) -> Void {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            let results = self.searchForString(searchString, scopeIndex: scopeIndex)
            DispatchQueue.main.async {
                onFinish(results)
            }
        }
    }
    func asyncSearchSpecialsForString(_ searchString: String, scopeIndex: Int, onFinish: @escaping ([Abbreviation]) -> Void) -> Void {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            let results = self.searchSpecialsForString(searchString, scopeIndex: scopeIndex)
            DispatchQueue.main.async {
                onFinish(results)
            }
        }
    }
    func asyncSearchFavoritesForString(_ searchString: String, scopeIndex: Int, onFinish: @escaping ([Abbreviation]) -> Void) -> Void {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            let results = self.searchFavoritesForString(searchString, scopeIndex: scopeIndex)
            DispatchQueue.main.async {
                onFinish(results)
            }
        }
    }
    
    // MARK: - Favorites
    
    let favoritesKey = "favorites"
    var favorites = NSMutableArray()
    
    var noFavorites: Bool {
        get {
            return favorites.count == 0
        }
    }
    
    func addFavorite(_ item: Abbreviation) {
        if !self.favorites.contains(item) {
            self.favorites.insert(item, at: 0)
        }
        //        println(self.favorites)
    }
    
    func removeFavorite(_ item: Abbreviation) {
        self.favorites.remove(item)
    }
    
    func saveFavorites() {
        let favoritesIDs = NSMutableArray()
        for favorite: Any in favorites {
            let abb = favorite as! Abbreviation
            favoritesIDs.insert(abb.id, at: 0)
        }
        let defaults = UserDefaults.standard
        defaults.set(favoritesIDs, forKey: favoritesKey)
        defaults.synchronize()
    }
    
    func moveFavoriteFromIndex(_ fromIndex: Int, toIndex: Int) {
        let fav: AnyObject = self.favorites[fromIndex] as AnyObject
        self.favorites.removeObject(at: fromIndex)
        self.favorites.insert(fav, at: toIndex)
    }
    
    // MARK: - Most Recently Viewed
    
    let recentlyViewedKey = "recentlyViewed"
    
    // Holds last 3 items viewed. Last item in array is the most recent item
    var recentlyViewed = NSMutableArray()
    
    let recentlyViewedCount = 2
    
    func pushViewed(abbreviation: Abbreviation) {
        if !recentlyViewed.contains(abbreviation) {
            if (recentlyViewed.count >= recentlyViewedCount) {
                self.recentlyViewed.removeObject(at: 0)
            }
            recentlyViewed.add(abbreviation)
        } else {
            recentlyViewed.remove(abbreviation)
            recentlyViewed.add(abbreviation)
        }
        updateShortcutItems()
    }
    
    func saveRecentlyViewed() {
        let recentlyViewedIDs = NSMutableArray()
        for recentlyViewed: Any in recentlyViewed {
            let abb = recentlyViewed as! Abbreviation
            recentlyViewedIDs.insert(abb.id, at: 0)
        }
        let defaults = UserDefaults.standard
        defaults.set(recentlyViewedIDs, forKey: recentlyViewedKey)
        defaults.synchronize()
    }
    
    private func updateShortcutItems() {
        if let _ = UIApplication.shared.shortcutItems {
            var newShortcutItems: [UIMutableApplicationShortcutItem] = []
            let shortcutType = AppDelegate.ShortcutIdentifier.openrecentlyviewed.type
            for i in 0..<recentlyViewed.count {
                let abbreviation = recentlyViewed[recentlyViewed.count - 1 - i] as! Abbreviation
                var shortcutTitle: String
                if let displayText = abbreviation.displayText {
                    shortcutTitle = displayText
                } else {
                    shortcutTitle = abbreviation.longText
                }
                newShortcutItems.append(UIMutableApplicationShortcutItem(
                    type: shortcutType,
                    localizedTitle: shortcutTitle,
                    localizedSubtitle: "Recently viewed",
                    icon: UIApplicationShortcutIcon(type: .time),
                    userInfo: [
                        "version": Bundle.main.infoDictionary!["CFBundleShortVersionString"]!,
                        "recentlyViewedIndex": i
                    ]
                ))
            }
            print("updating shortcutItems with \(newShortcutItems)")
            UIApplication.shared.shortcutItems = newShortcutItems;
        }
    }
    
    // 0 is most recently viewed, 1 is second most recently viewed, etc.
    func getRecentlyViewedIndex(index: Int) -> Abbreviation? {
        if recentlyViewed.count > index {
            return recentlyViewed[recentlyViewed.count - 1 - index] as? Abbreviation
        } else {
            return nil
        }
    }
}
