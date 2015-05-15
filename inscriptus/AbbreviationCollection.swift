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
    
    // Abbreviations in a dictionary by their search text
    var abbreviationsGrouped = [String: Array<Abbreviation>]()
    var abbreviationsGroupedByFirstLetter = [String: Array<Abbreviation>]()
    var abbreviationsFirstLetters: [String]
    var specialAbbreviations = [Abbreviation]()
    var allAbbreviations = [Abbreviation]()
    
    class var sharedAbbreviationCollection: AbbreviationCollection {
        return _SingletonSharedInstance
    }
    
    override init() {
        // Load abbreviations arrays
        let combinedPath: String = NSBundle.mainBundle().pathForResource("abbs-combined", ofType: "json")!
        let combinedData = NSData(contentsOfFile: combinedPath)!
        var err: NSError?
        let combinedAbbreviations: NSArray = NSJSONSerialization.JSONObjectWithData(combinedData, options: .allZeros, error: &err) as! NSArray
        
        var abbreviations = [Abbreviation]()
        for abbreviation in combinedAbbreviations {
            abbreviations.append(Abbreviation(JSONDict: abbreviation as! NSDictionary))
        }
        
        self.allAbbreviations = abbreviations
        
        // Special character abbreviations
        
        let specialcharsPath: String = NSBundle.mainBundle().pathForResource("abbs-specialchars", ofType: "json")!
        let specialcharData = NSData(contentsOfFile: specialcharsPath)!
        let specialcharAbbreviations: NSArray = NSJSONSerialization.JSONObjectWithData(specialcharData, options: .allZeros, error: &err) as! NSArray
        for abbreviation in specialcharAbbreviations {
            self.specialAbbreviations.append(Abbreviation(JSONDict: abbreviation as! NSDictionary))
        }
        
        // create dictionary of abbreviations grouped by search string
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
        
        for abb in self.allAbbreviations {
            if let searchStrs = abb.searchStrings {
                for searchString in searchStrs {
                    // Section title should be "#" if abb begins with a number or symbol
                    let char = NSCharacterSet.letterCharacterSet().characterIsMember(searchString[0..<1].utf16[String.UTF16View.Index(0)]) ? searchString[0..<1] : "#"
                    if self.abbreviationsGroupedByFirstLetter[char] != nil {
                        self.abbreviationsGroupedByFirstLetter[char]!.append(abb)
                    }
                    else {
                        self.abbreviationsGroupedByFirstLetter[char] = [abb]
                    }
                }
            }
        }
        
        self.abbreviationsFirstLetters = sorted(self.abbreviationsGroupedByFirstLetter.keys, {
            (a: String, b: String) in
            a.compare(b, options: .CaseInsensitiveSearch) == .OrderedAscending
        })
        
        super.init()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let storedFavorites: AnyObject = defaults.objectForKey(favoritesKey) {
            for favorite: AnyObject in storedFavorites as! NSMutableArray {
                println(favorite)
                self.favorites.insertObject(abbreviationWithID(favorite as! NSInteger)!, atIndex: 0)
            }
        }
    }
    
    func abbreviationWithID(id: Int) -> Abbreviation? {
        var abb = self.allAbbreviations[id]
        var i = id
        while(abb.id != id) {
            abb = self.allAbbreviations[--i]
        }
        return abb
    }
    
    func searchForString(searchString: String, scopeIndex: Int) -> [Abbreviation] {
        var resultAbbreviations = Set<Abbreviation>()
        
        if scopeIndex == MasterViewController.searchScopeIndexAbbreviation {
            // Try to do an exact match
            if let matchingAbbreviations = self.abbreviationsGrouped[searchString.uppercaseString] {
                resultAbbreviations = Set(matchingAbbreviations)
            }
            
            // Do a partial match too
            var i = 0
            for key: String in self.abbreviationsGrouped.keys {
                if key.rangeOfString(searchString.lowercaseString, options: .CaseInsensitiveSearch) != nil || key.rangeOfString(searchString.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: ""), options: .CaseInsensitiveSearch) != nil {
                    if let matchingAbbreviations: [Abbreviation] = self.abbreviationsGrouped[key] {
                        resultAbbreviations.unionInPlace(matchingAbbreviations)
                    }
                }
            }
        }
        else if scopeIndex == MasterViewController.searchScopeIndexFulltext {
            for abbreviation: Abbreviation in allAbbreviations {
                if abbreviation.longText.rangeOfString(searchString, options: .CaseInsensitiveSearch) != nil {
                    resultAbbreviations.insert(abbreviation)
                }
            }
        }
        
        return sorted(Array(resultAbbreviations), {
            (a1: Abbreviation, a2: Abbreviation) in
            let a1Text = a1.displayText != nil ? a1.displayText! : a1.longText
            let a2Text = a2.displayText != nil ? a2.displayText! : a2.longText
            let a1SearchPos = a1Text.rangeOfString(searchString, options: .CaseInsensitiveSearch)?.startIndex
            let a2SearchPos = a2Text.rangeOfString(searchString, options: .CaseInsensitiveSearch)?.startIndex
            if a1SearchPos == a1Text.startIndex && a2SearchPos != a2Text.startIndex {
                return true
            }
            if a2SearchPos == a2Text.startIndex && a1SearchPos != a1Text.startIndex {
                return false
            }
            return a1Text.compare(a2Text) == .OrderedAscending
        })
    }
    
    func searchSpecialsForString(searchString: String, scopeIndex: Int) -> [Abbreviation] {
        var resultAbbreviations = Set<Abbreviation>()
        
        if scopeIndex == MasterViewController.searchScopeIndexAbbreviation {
            // Do a partial match too
            var i = 0
            for abb: Abbreviation in self.specialAbbreviations {
                if let abbSearchableStrings = abb.searchStrings {
                    for str: String in abbSearchableStrings {
                        if str.rangeOfString(searchString.lowercaseString, options: .CaseInsensitiveSearch) != nil || str.rangeOfString(searchString.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: ""), options: .CaseInsensitiveSearch) != nil {
                            resultAbbreviations.insert(abb)
                        }
                    }
                }
            }
        }
        else if scopeIndex == MasterViewController.searchScopeIndexFulltext {
            for abbreviation: Abbreviation in self.specialAbbreviations {
                if abbreviation.longText.rangeOfString(searchString, options: .CaseInsensitiveSearch) != nil {
                    resultAbbreviations.insert(abbreviation)
                }
            }
        }
        
        return sorted(Array(resultAbbreviations), {
            (a1: Abbreviation, a2: Abbreviation) in
            let a1Text = a1.displayText != nil ? a1.displayText! : a1.longText
            let a2Text = a2.displayText != nil ? a2.displayText! : a2.longText
            let a1SearchPos = a1Text.rangeOfString(searchString, options: .CaseInsensitiveSearch)?.startIndex
            let a2SearchPos = a2Text.rangeOfString(searchString, options: .CaseInsensitiveSearch)?.startIndex
            if a1SearchPos == a1Text.startIndex && a2SearchPos != a2Text.startIndex {
                return true
            }
            if a2SearchPos == a2Text.startIndex && a1SearchPos != a1Text.startIndex {
                return false
            }
            return a1Text.compare(a2Text) == .OrderedAscending
        })
    }
    
    
    // Does not sort the results like the other search functions
    func searchFavoritesForString(searchString: String, scopeIndex: Int) -> [Abbreviation] {
        var resultAbbreviations = [Abbreviation]()
        
        if scopeIndex == MasterViewController.searchScopeIndexAbbreviation {
            // Do a partial match too
            var i = 0
            for favorite: AnyObject in self.favorites {
                let abb = favorite as! Abbreviation
                if let abbSearchableStrings = abb.searchStrings {
                    for str: String in abbSearchableStrings {
                        if str.rangeOfString(searchString.lowercaseString, options: .CaseInsensitiveSearch) != nil || str.rangeOfString(searchString.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: ""), options: .CaseInsensitiveSearch) != nil {
                            resultAbbreviations.append(abb)
                        }
                    }
                }
            }
        }
        else if scopeIndex == MasterViewController.searchScopeIndexFulltext {
            for favorite: AnyObject in self.favorites {
                let abbreviation = favorite as! Abbreviation
                if abbreviation.longText.rangeOfString(searchString, options: .CaseInsensitiveSearch) != nil {
                    resultAbbreviations.append(abbreviation)
                }
            }
        }
        
        return resultAbbreviations
    }
    
    func asyncSearchForString(searchString: String, scopeIndex: Int, onFinish: ([Abbreviation]) -> Void) -> Void {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let results = self.searchForString(searchString, scopeIndex: scopeIndex)
            dispatch_async(dispatch_get_main_queue()) {
                onFinish(results)
            }
        }
    }
    
    func asyncSearchSpecialsForString(searchString: String, scopeIndex: Int, onFinish: ([Abbreviation]) -> Void) -> Void {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let results = self.searchSpecialsForString(searchString, scopeIndex: scopeIndex)
            dispatch_async(dispatch_get_main_queue()) {
                onFinish(results)
            }
        }
    }
    
    func asyncSearchFavoritesForString(searchString: String, scopeIndex: Int, onFinish: ([Abbreviation]) -> Void) -> Void {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let results = self.searchFavoritesForString(searchString, scopeIndex: scopeIndex)
            dispatch_async(dispatch_get_main_queue()) {
                onFinish(results)
            }
        }
    }
    
    //MARK: - Favorites
    
    let favoritesKey = "favorites"
    var favorites = NSMutableArray()
    
    var noFavorites: Bool {
        get {
            return favorites.count == 0
        }
    }
    
    func addFavorite(item: Abbreviation) {
        if !self.favorites.containsObject(item) {
            self.favorites.insertObject(item, atIndex: 0)
        }
        //        println(self.favorites)
    }
    
    func removeFavorite(item: Abbreviation) {
        self.favorites.removeObject(item)
    }
    
    func saveFavorites() {
        var favoritesIDs = NSMutableArray()
        for favorite: AnyObject in favorites {
            let abb = favorite as! Abbreviation
            favoritesIDs.insertObject(abb.id, atIndex: 0)
        }
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(favoritesIDs, forKey: favoritesKey)
        defaults.synchronize()
    }
    
    func moveFavoriteFromIndex(fromIndex: Int, toIndex: Int) {
        let fav: AnyObject = self.favorites[fromIndex]
        self.favorites.removeObjectAtIndex(fromIndex)
        self.favorites.insertObject(fav, atIndex: toIndex)
    }
}
