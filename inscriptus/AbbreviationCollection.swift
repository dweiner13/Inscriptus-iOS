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
        var resultAbbreviations = [Abbreviation]()
        
        if scopeIndex == MasterViewController.searchScopeIndexAbbreviation {
            // Try to do an exact match
            if let matchingAbbreviations = self.abbreviationsGrouped[searchString.uppercaseString] {
                resultAbbreviations = matchingAbbreviations
            }
            
            // Do a partial match too
            var i = 0
            for key: String in self.abbreviationsGrouped.keys {
                if key.rangeOfString(searchString.lowercaseString, options: .CaseInsensitiveSearch) != nil || key.rangeOfString(searchString.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.allZeros), options: .CaseInsensitiveSearch) != nil {
                    if let matchingAbbreviations: [Abbreviation] = self.abbreviationsGrouped[key] {
                        resultAbbreviations.extend(matchingAbbreviations)
                    }
                }
            }
        }
        else if scopeIndex == MasterViewController.searchScopeIndexFulltext {
            for abbreviation: Abbreviation in allAbbreviations {
                if abbreviation.longText.rangeOfString(searchString, options: .CaseInsensitiveSearch) != nil {
                    resultAbbreviations.append(abbreviation)
                }
            }
        }
        
        return resultAbbreviations
    }
}
