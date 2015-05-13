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
        
        super.init()
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
}
